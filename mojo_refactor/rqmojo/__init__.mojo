"""
RQMojo - RQAlpha Mojo Implementation
"""

from rqmojo._version import Version, get_version
# from .cmds import run as cmd_run
# from .api import export_as_api
# from .apis import subscribe_event
# from . import data
# from . import interface
# from . import portfolio
# from . import apis


fn load_ipython_extension():
    """call by ipython"""
    # from rqalpha.mod.utils import inject_mod_commands
    # inject_mod_commands()
    # ipython.register_magic_function(run_ipython_cell, 'line_cell', 'rqalpha')
    print("load_ipython_extension not implemented")


fn run(config: String, source_code: String = ""):
    # [Deprecated]
    # from rqalpha.utils.config import parse_config
    # from rqalpha import main

    # config = parse_config(config, source_code=source_code)
    # return main.run(config, source_code=source_code)
    print("run not implemented")


fn run_ipython_cell(line: String, cell: String = ""):
    # from rqalpha.cmds.run import run
    # from rqalpha.utils.functools import clear_all_cached_functions
    # clear_all_cached_functions()
    # args = line.split()
    # args.extend(["--source-code", cell if cell is not None else ""])
    # try:
    #     # It raise exception every time
    #     run.main(args, standalone_mode=True)
    # except SystemExit as e:
    #     pass
    print("run_ipython_cell not implemented")


fn run_file(strategy_file_path: String, config: String = ""):
    """
    传入策略文件路径运行回测。
    """
    # from rqalpha.utils.config import parse_config
    # from rqalpha.utils.functools import clear_all_cached_functions
    # from rqalpha import main

    # if config is None:
    #     config = {
    #         "base": {
    #             "strategy_file": strategy_file_path
    #         }
    #     }
    # else:
    #     assert isinstance(config, dict)
    #     if "base" in config:
    #         config["base"]["strategy_file"] = strategy_file_path
    print("run_file not implemented")


fn run_code(code: String, config: String = "") -> String:
    """
    传入字符串形式的策略代码以运行回测。
    """
    print("run_code not implemented")
    return "{}"


fn run_func(config: String) -> String:
    """
    传入约定函数和策略配置运行回测。
    """
    print("run_func not implemented")
    return "{}"


fn main():
    """RQMojo main entry point."""
    print("RQMojo - RQAlpha Mojo Implementation")
    print("Version:", get_version())
