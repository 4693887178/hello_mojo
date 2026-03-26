# Test Result: test_api.mojo

Test Date: Thu Mar 26 17:40:17 CST 2026

## Test Output
```
Failed to initialize Crashpad.  Crash reporting will not be available.  Cause: while locating crashpad handler: unable to locate crashpad handler executable
Included from /home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_api.mojo:6:
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/./rqmojo/api.mojo:10:1: error: global vars are not supported
var __all__: List[String] = List[String]()
^
Included from /home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_api.mojo:6:
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/./rqmojo/api.mojo:7:6: warning: Implicit standard library imports are deprecated and will be removed in a future release; fully qualify with 'std.' instead
from utils import FunctionType
     ^
     std.
Included from /home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_api.mojo:6:
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/./rqmojo/api.mojo:7:19: error: package 'utils' does not contain 'FunctionType'
from utils import FunctionType
                  ^
/home/zhou/hello_mojo/trae_cn_78/.venv/bin/mojo: error: failed to parse the provided Mojo source module
```

## Result
Status: **FAILED**
