# Test Result: test_bundle.mojo

Test Date: Thu Mar 26 17:40:18 CST 2026

## Test Output
```
Failed to initialize Crashpad.  Crash reporting will not be available.  Cause: while locating crashpad handler: unable to locate crashpad handler executable
Included from /home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_bundle.mojo:6:
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/./rqmojo/cmds/bundle.mojo:7:42: error: expected name to import 'gettext' as
from rqmojo.utils.i18n import gettext as _
                                         ^
Included from /home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_bundle.mojo:6:
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/./rqmojo/cmds/bundle.mojo:7:42: note: escape keyword '_' with backticks to use it as an identifier
from rqmojo.utils.i18n import gettext as _
                                         ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_bundle.mojo:6:32: error: module 'bundle' does not contain 'update_bundle'
from rqmojo.cmds.bundle import update_bundle, create_bundle, download_bundle, check_bundle
                               ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_bundle.mojo:6:47: error: module 'bundle' does not contain 'create_bundle'
from rqmojo.cmds.bundle import update_bundle, create_bundle, download_bundle, check_bundle
                                              ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_bundle.mojo:6:62: error: module 'bundle' does not contain 'download_bundle'
from rqmojo.cmds.bundle import update_bundle, create_bundle, download_bundle, check_bundle
                                                             ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_bundle.mojo:6:79: error: module 'bundle' does not contain 'check_bundle'
from rqmojo.cmds.bundle import update_bundle, create_bundle, download_bundle, check_bundle
                                                                              ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_bundle.mojo:7:32: error: module 'bundle' does not contain 'BundleConfig'
from rqmojo.cmds.bundle import BundleConfig
                               ^
/home/zhou/hello_mojo/trae_cn_78/.venv/bin/mojo: error: failed to parse the provided Mojo source module
```

## Result
Status: **FAILED**
