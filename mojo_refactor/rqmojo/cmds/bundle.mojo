"""
RQAlpha Mojo - Bundle Command
Ported from rqalpha/cmds/bundle.py

CLI commands:
  - create_bundle:  Create data bundle using RQDatac (requires Python rqdatac)
  - update_bundle:  Update existing bundle using RQDatac
  - download_bundle: Download monthly-updated bundle from CDN
  - check_bundle:    Validate bundle data integrity (HDF5)

Utility functions:
  - get_exactly_url:   Resolve current CDN URL by probing month-by-month
  - download:          HTTP download with Range-header resume & retry
  - check_bundle_data: Scan .h5 instruments for corruption

Uses argmojo for CLI (replacing click).
Uses std.python interop for requests/h5py/rqdatac.
"""

from std.collections import List, Dict
from std.os import getenv, makedirs, remove, listdir
from std.os.path import exists as path_exists
from std.pathlib import Path

from std.python import Python, PythonObject
from argmojo import Command, Argument, ParseResult
from morrow import Morrow, TimeDelta, TimeZone
from rqmojo.utils.i18n import gettext
from rqmojo.utils.logger import system_log


comptime DEFAULT_BUNDLE_PATH = "~/.rqalpha"

comptime RETRY_INTERVAL = 3

comptime RETRY_TIMES = 5

comptime CHUNK_SIZE = 8192


def _format_cdn_url(year: Int, month: Int) -> String:
    """Format CDN URL with zero-padded year/month."""
    var y_str = String(year).ascii_rjust(4, "0")
    var m_str = String(month).ascii_rjust(2, "0")
    return "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_" + y_str + m_str + ".tar.bz2"


def _expanduser(path: String) raises -> String:
    """Replace leading ~ with user home directory."""
    if len(path) >= 1 and path[byte=0] == '~':
        var py_os = Python.import_module("os")
        var home = String(py=py_os.path.expanduser("~"))
        if len(path) == 1:
            return home
        return home + path[byte=1:]
    return path


def _get_proxy_env() -> String:
    """Read RQALPHA_PROXY environment variable."""
    return getenv("RQALPHA_PROXY")


def run_create_bundle(
    data_bundle_path: String,
    rqdatac_uri: String,
    compression: Bool,
    concurrency: Int,
) raises -> Int:
    """Core logic: create bundle using RQDatac.

    Ported from Python create_bundle().
    Returns 0 on success, 1 on error.
    """
    from std.python import Python, PythonObject

    try:
        _ = Python.import_module("rqdatac")
    except e:
        system_log().error(gettext(
            "rqdatac is required to create bundle. "
            "you can visit https://www.ricequant.com/welcome/rqdata to get rqdatac, "
            'or use "rqalpha download-bundle" to download monthly updated bundle.'
        ))
        return 1

    try:
        var init_fn = Python.import_module("rqalpha.utils").init_rqdatac_env
        init_fn(rqdatac_uri)
        var rqdatac_mod = Python.import_module("rqdatac")
        rqdatac_mod.init()
    except e:
        system_log().error(gettext("rqdatac init failed with error: {}").format(String(e)))
        return 1

    var expanded = _expanduser(data_bundle_path)
    var bundle_dir = expanded + "/bundle"
    makedirs(bundle_dir)

    var bundle_mod = Python.import_module("rqalpha.data.bundle")
    bundle_mod.update_bundle(bundle_dir, True, compression, concurrency)
    return 0


def run_update_bundle(
    data_bundle_path: String,
    rqdatac_uri: String,
    compression: Bool,
    concurrency: Int,
) raises -> Int:
    """Core logic: update existing bundle using RQDatac.

    Ported from Python update_bundle().
    Returns 0 on success, 1 on error.
    """
    from std.python import Python, PythonObject

    try:
        _ = Python.import_module("rqdatac")
    except e:
        system_log().error(gettext(
            "rqdatac is required to update bundle. "
            "you can visit https://www.ricequant.com/welcome/rqdata to get rqdatac, "
            'or use "rqalpha download-bundle" to download monthly updated bundle.'
        ))
        return 1

    try:
        var init_fn = Python.import_module("rqalpha.utils").init_rqdatac_env
        init_fn(rqdatac_uri)
        var rqdatac_mod = Python.import_module("rqdatac")
        rqdatac_mod.init()
    except e:
        system_log().error(gettext("rqdatac init failed with error: {}").format(String(e)))
        return 1

    var expanded = _expanduser(data_bundle_path)
    var bundle_dir = expanded + "/bundle"
    if not path_exists(bundle_dir):
        system_log().error(gettext('bundle not exist, use "rqalpha create-bundle" command instead'))
        return 1

    var bundle_mod = Python.import_module("rqalpha.data.bundle")
    var succeed = bundle_mod.update_bundle(bundle_dir, False, compression, concurrency)
    if not Bool(py=succeed):
        raise Error("update_bundle failed")
    return 0


def run_download_bundle(data_bundle_path: String, confirm: Bool) raises -> Int:
    """Core logic: download monthly-updated bundle from CDN.

    Ported from Python download_bundle().
    Downloads tar.bz2, extracts, cleans up temp file.
    Returns 0 on success, 1 on error.
    """
    from std.python import Python, PythonObject
    var py_os = Python.import_module("os")
    var py_shutil = Python.import_module("shutil")
    var py_tarfile = Python.import_module("tarfile")
    var py_tempfile = Python.import_module("tempfile")

    var default_bundle_path = String(py=py_os.path.abspath(
        py_os.path.join(_expanduser("~/.rqalpha"), "bundle")
    ))

    var target_path: String
    if len(data_bundle_path) == 0 or data_bundle_path == DEFAULT_BUNDLE_PATH:
        target_path = default_bundle_path
    else:
        target_path = String(py=py_os.path.abspath(
            py_os.path.join(data_bundle_path, "./bundle/")
        ))

    if confirm and path_exists(target_path) and target_path != default_bundle_path:
        var entries = listdir(target_path)
        if len(entries) > 0:
            print(gettext(
                "\n    [WARNING]\n"
                "    Target bundle path " + target_path + " is not empty.\n"
                "    The content of this folder will be REMOVED before updating.\n"
                "    Are you sure to continue?"
            ))
            print("(y/n): ", end="")
            var answer = input()
            if answer != "y" and answer != "yes":
                print("Aborted.")
                return 1

    var tmp_dir = String(py=py_tempfile.gettempdir())
    var tmp_path = tmp_dir + "/rq.bundle"

    var url: String = ""
    var total_length: Int = 0
    var result = get_exactly_url(url, total_length)

    var f_out = open(tmp_path, "wb")
    f_out.close()
    var dl_ok = download(tmp_path, total_length, url)

    if not dl_ok:
        remove(tmp_path)
        return 1

    py_shutil.rmtree(target_path, ignore_errors=True)
    makedirs(target_path)

    var tar = py_tarfile.open(tmp_path, "r:bz2")
    tar.extractall(target_path)
    tar.close()
    remove(tmp_path)

    print(gettext("Data bundle download successfully in ") + target_path)
    return 0


def run_check_bundle(data_bundle_path: String) raises -> Int:
    """Core logic: validate bundle data integrity.

    Ported from Python check_bundle().
    Returns 0 on success, 1 on error.
    """
    var expanded = _expanduser(data_bundle_path)
    var bundle_dir = expanded + "/bundle"
    check_bundle_data(bundle_dir)
    return 0


def get_exactly_url(mut out_url: String, mut out_total_length: Int) raises -> Bool:
    """Probe CDN to find the latest available bundle URL.

    Starts from current month and goes backwards month-by-month
    until a URL returns HTTP 200.

    Ported from Python get_exactly_url().
    Sets out_url and out_total_length by reference.
    Returns True on success.
    """
    from std.python import Python, PythonObject
    var requests = Python.import_module("requests")

    var today = Morrow.now()
    var year = today.year
    var month = today.month
    var proxy = _get_proxy_env()

    while True:
        var url = _format_cdn_url(year, month)
        print(gettext("try {} ...").format(url))

        var proxies: PythonObject = Python.dict(http=proxy, https=proxy)
        var r = requests.get(url, stream=True, proxies=proxies)
        var status_code = Int(py=r.status_code)

        if status_code == 200:
            out_url = url
            var content_length = r.headers.get("content-length")
            if Bool(py=content_length.__bool__()):
                out_total_length = Int(py=content_length)
            else:
                out_total_length = 0
            return True

        month -= 1
        if month < 1:
            month = 12
            year -= 1


def download(out_path: String, total_length: Int, url: String) raises -> Bool:
    """Download bundle from URL with progress reporting, retry, and Range-header resume.

    Ported from Python download().
    Returns True on successful completion.
    """
    var requests = Python.import_module("requests")
    var time_mod = Python.import_module("time")
    var py_builtin = Python.import_module("builtins")

    var proxy = _get_proxy_env()
    var proxies: PythonObject = Python.dict(http=proxy, https=proxy)
    var pos = 0

    print(gettext("downloading ...") + " [total: " + String(total_length) + " bytes]")

    var f_out = py_builtin.open(out_path, "wb")

    for i in range(RETRY_TIMES):
        try:
            var range_header = "bytes={}-".format(String(pos))
            var headers: PythonObject = Python.dict(Range=range_header)
            var r = requests.get(
                url,
                headers=headers,
                stream=True,
                timeout=10,
                proxies=proxies,
            )

            var iterator = r.iter_content(chunk_size=CHUNK_SIZE)
            while True:
                try:
                    var data = py_builtin.next(iterator)
                    var data_len = Int(py=len(data))
                    pos += data_len
                    f_out.write(data)
                except StopIteration:
                    break

            if total_length == 0 or pos >= total_length:
                f_out.close()
                return True

        except e:
            if i < RETRY_TIMES - 1:
                print(gettext("\nDownload failed, retry in {} seconds.").format(String(RETRY_INTERVAL)))
                time_mod.sleep(RETRY_INTERVAL)
            else:
                f_out.close()
                raise e^

    f_out.close()
    return False


def check_bundle_data(data_bundle_path: String) raises -> None:
    """Check bundle data integrity by scanning instrument .h5 files.

    For each instrument type (stocks/indexes/futures/funds), opens the
    HDF5 file and reads first row of each order_book_id dataset to
    verify file integrity.

    Ported from Python check_bundle_data().
    Reports corrupt files and offers to remove them.
    """
    from std.python import Python, PythonObject
    var h5py = Python.import_module("h5py")

    var instruments = ["stocks", "indexes", "futures", "funds"]
    var corrupt_files = List[String]()
    var not_exists_instruments = List[String]()

    for instrument in instruments:
        var h5_path = data_bundle_path + "/" + instrument + ".h5"
        if not path_exists(h5_path):
            not_exists_instruments.append(instrument)
            continue

        try:
            var f = h5py.File(h5_path, mode="r")
            var py_keys = f.keys()
            var py_list = Python.import_module("builtins").list
            var keys = py_list(py_keys)
            for k_idx in range(len(keys)):
                var k = keys[k_idx]
                var key_str = String(py=k)
                _ = f[key_str][:1]
            f.close()
        except e:
            corrupt_files.append(h5_path)

    if len(corrupt_files) > 0:
        print(gettext("corrupted files:") + ":")
        for cf in corrupt_files:
            print("  ", cf)
        print(gettext("remove files") + "(yes/no):", end=" ")
        var is_ok = input().lower()
        if is_ok == "yes" or is_ok == "y":
            for cf in corrupt_files:
                remove(cf)
            print(gettext("remove success"))
        elif is_ok == "no" or is_ok == "n":
            print(gettext("corrupted files not remove"))
        else:
            print(gettext("input error"))
    elif len(not_exists_instruments) > 0:
        print(gettext("bundle's day bar is incomplete, please update bundle"))
    else:
        print(gettext("good bundle's day bar"))


# ── Backward-compatible aliases (matching Python function names) ────────


def create_bundle(
    data_bundle_path: String,
    rqdatac_uri: String = "",
    compression: Bool = False,
    concurrency: Int = 1,
) raises -> Int:
    """Alias for run_create_bundle(). Matches Python signature."""
    return run_create_bundle(data_bundle_path, rqdatac_uri, compression, concurrency)


def update_bundle(
    data_bundle_path: String,
    rqdatac_uri: String = "",
    compression: Bool = False,
    concurrency: Int = 1,
) raises -> Int:
    """Alias for run_update_bundle(). Matches Python signature."""
    return run_update_bundle(data_bundle_path, rqdatac_uri, compression, concurrency)


def download_bundle(
    data_bundle_path: String = "",
    confirm: Bool = True,
) raises -> Int:
    """Alias for run_download_bundle(). Matches Python signature."""
    return run_download_bundle(data_bundle_path, confirm)


def check_bundle(data_bundle_path: String = "") raises -> Int:
    """Alias for run_check_bundle(). Matches Python signature."""
    return run_check_bundle(data_bundle_path)


# ── argmojo CLI Commands (replacing @click decorators) ──────────────────


def create_create_bundle_command() raises -> Command:
    """Create the 'create_bundle' subcommand using argmojo.

    Replaces: @cli.command(help=_("create bundle using RQDatac"))
    """
    var cmd = Command("create_bundle", gettext("create bundle using RQDatac"))
    cmd.add_argument(
        Argument("data_bundle_path", help="Data bundle storage path")
            .long["data-bundle-path"]()
            .short["d"]()
            .default[DEFAULT_BUNDLE_PATH]()
    )
    cmd.add_argument(
        Argument("rqdatac_uri", help="rqdatac uri, eg user:password or tcp://user:password@ip:port")
            .long["rqdatac"]()
            .long["rqdatac-uri"]()
            .default[""]()
    )
    cmd.add_argument(
        Argument("compression", help="enable compression to reduce file size")
            .long["compression"]()
            .flag()
    )
    cmd.add_argument(
        Argument("concurrency", help="number of concurrent downloads")
            .long["concurrency"]()
            .short["c"]()
            .default["1"]()
    )
    return cmd^


def create_update_bundle_command() raises -> Command:
    """Create the 'update_bundle' subcommand using argmojo.

    Replaces: @cli.command(help=_("Update bundle using RQDatac"))
    """
    var cmd = Command("update_bundle", gettext("Update bundle using RQDatac"))
    cmd.add_argument(
        Argument("data_bundle_path", help="Data bundle storage path")
            .long["data-bundle-path"]()
            .short["d"]()
            .default[DEFAULT_BUNDLE_PATH]()
    )
    cmd.add_argument(
        Argument("rqdatac_uri", help="rqdatac uri, eg user:password or tcp://user:password@ip:port")
            .long["rqdatac"]()
            .long["rqdatac-uri"]()
            .default[""]()
    )
    cmd.add_argument(
        Argument("compression", help="enable compression to reduce file size")
            .long["compression"]()
            .flag()
    )
    cmd.add_argument(
        Argument("concurrency", help="number of concurrent downloads")
            .long["concurrency"]()
            .short["c"]()
            .default["1"]()
    )
    return cmd^


def create_download_bundle_command() raises -> Command:
    """Create the 'download_bundle' subcommand using argmojo.

    Replaces: @cli.command(help=_("Download bundle (monthly updated)"))
    """
    var cmd = Command("download_bundle", gettext("Download bundle (monthly updated)"))
    cmd.add_argument(
        Argument("data_bundle_path", help="Data bundle storage path")
            .long["data-bundle-path"]()
            .short["d"]()
            .default[DEFAULT_BUNDLE_PATH]()
    )
    cmd.add_argument(
        Argument("confirm", help="confirm before overwriting existing bundle")
            .long["confirm"]()
            .flag()
    )
    return cmd^


def create_check_bundle_command() raises -> Command:
    """Create the 'check_bundle' subcommand using argmojo.

    Replaces: @cli.command(help=_("Check bundle"))
    """
    var cmd = Command("check_bundle", gettext("Check bundle"))
    cmd.add_argument(
        Argument("data_bundle_path", help="Data bundle storage path")
            .long["data-bundle-path"]()
            .short["d"]()
            .default[DEFAULT_BUNDLE_PATH]()
    )
    return cmd^


def register_bundle_commands(mut cli: Command) raises -> None:
    """Register all bundle subcommands onto the main CLI group.

    Call this from entry.mojo after creating the root cli Command.
    Equivalent to Python's @cli.command() decorator pattern.
    """
    cli.add_subcommand(create_create_bundle_command())
    cli.add_subcommand(create_update_bundle_command())
    cli.add_subcommand(create_download_bundle_command())
    cli.add_subcommand(create_check_bundle_command())


def dispatch_bundle_command(result: ParseResult) raises -> Int:
    """Dispatch to the correct core function based on parsed subcommand result.

    Args:
        result: ParseResult from cli.parse() where subcommand is one of
                create_bundle, update_bundle, download_bundle, check_bundle.

    Returns:
        Exit code (0 = success, 1 = error).
    """
    var sub_name = result.subcommand
    var sub_result = result.get_subcommand_result()

    if sub_name == "create_bundle":
        var data_path = sub_result.get_string("data_bundle_path")
        var rqdatac_uri = sub_result.get_string("rqdatac_uri")
        var compression = sub_result.get_flag("compression")
        var concurrency = Int(sub_result.get_string("concurrency"))
        return run_create_bundle(data_path, rqdatac_uri, compression, concurrency)

    elif sub_name == "update_bundle":
        var data_path = sub_result.get_string("data_bundle_path")
        var rqdatac_uri = sub_result.get_string("rqdatac_uri")
        var compression = sub_result.get_flag("compression")
        var concurrency = Int(sub_result.get_string("concurrency"))
        return run_update_bundle(data_path, rqdatac_uri, compression, concurrency)

    elif sub_name == "download_bundle":
        var data_path = sub_result.get_string("data_bundle_path")
        var confirm = sub_result.get_flag("confirm")
        return run_download_bundle(data_path, confirm)

    elif sub_name == "check_bundle":
        var data_path = sub_result.get_string("data_bundle_path")
        return run_check_bundle(data_path)

    else:
        print("Unknown bundle command: ", sub_name)
        return 1
