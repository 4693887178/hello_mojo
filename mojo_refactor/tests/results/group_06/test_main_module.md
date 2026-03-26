# Test Result: test_main_module.mojo

Test Date: Thu Mar 26 17:40:16 CST 2026

## Test Output
```
Failed to initialize Crashpad.  Crash reporting will not be available.  Cause: while locating crashpad handler: unable to locate crashpad handler executable
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_main_module.mojo:30:5: error: invalid redefinition of 'main'
def main() -> None:
    ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_main_module.mojo:6:6: note: cannot overload with this non-function definition
from rqmojo.__main__ import entry_point, main
     ^
Included from /home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_main_module.mojo:6:
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/./rqmojo/__main__.mojo:14:5: error: defining 'main' within a package is not yet supported
def main() -> None:
    ^
/home/zhou/hello_mojo/trae_cn_78/.venv/bin/mojo: error: failed to parse the provided Mojo source module
```

## Result
Status: **FAILED**
