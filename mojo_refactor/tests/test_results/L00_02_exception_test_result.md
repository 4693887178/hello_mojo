# L00-02 exception Module Test Result

## Test Information

| Item | Value |
|------|-------|
| Module | rqmojo.utils.exception / rqalpha.utils.exception |
| Level | L00 - Leaf module |
| Dependencies | const |
| Test Date | 2026-03-02 |

## Python Test Results

### Test Command

```bash
.venv/bin/python -m pytest tests/python_test_rqalpha/L00_leaf/test_L00_02_exception.py -v
```

### Test Statistics

| Metric | Value |
|--------|-------|
| Test Cases | 30 |
| Passed | 30 |
| Failed | 0 |
| Execution Time | 3.20s |

### Test Output

```
============================= test session starts ==============================
platform linux -- Python 3.14.3, pytest-9.0.2, pluggy-1.6.0
collected 30 items

test_L00_02_exception.py::TestL00Exception::TestCustomError::test_init PASSED
test_L00_02_exception.py::TestL00Exception::TestCustomError::test_set_msg PASSED
test_L00_02_exception.py::TestL00Exception::TestCustomError::test_add_stack_info PASSED
test_L00_02_exception.py::TestL00Exception::TestCustomError::test_repr_empty PASSED
test_L00_02_exception.py::TestL00Exception::TestCustomError::test_repr_with_stacks PASSED
test_L00_02_exception.py::TestL00Exception::TestCustomException::test_init PASSED
test_L00_02_exception.py::TestL00Exception::TestRQUserError::test_init PASSED
test_L00_02_exception.py::TestL00Exception::TestRQUserError::test_inheritance PASSED
test_L00_02_exception.py::TestL00Exception::TestRQInvalidArgument::test_init PASSED
test_L00_02_exception.py::TestL00Exception::TestRQInvalidArgument::test_inheritance PASSED
test_L00_02_exception.py::TestL00Exception::TestRQTypeError::test_init PASSED
test_L00_02_exception.py::TestL00Exception::TestRQTypeError::test_inheritance PASSED
test_L00_02_exception.py::TestL00Exception::TestRQApiNotSupportedError::test_init PASSED
test_L00_02_exception.py::TestL00Exception::TestRQApiNotSupportedError::test_inheritance PASSED
test_L00_02_exception.py::TestL00Exception::TestRQDatacVersionTooLow::test_init PASSED
test_L00_02_exception.py::TestL00Exception::TestRQDatacVersionTooLow::test_inheritance PASSED
test_L00_02_exception.py::TestL00Exception::TestInstrumentNotFound::test_init PASSED
test_L00_02_exception.py::TestL00Exception::TestInstrumentNotFound::test_inheritance PASSED
test_L00_02_exception.py::TestL00Exception::TestEnvironmentNotInitialized::test_init PASSED
test_L00_02_exception.py::TestL00Exception::TestEnvironmentNotInitialized::test_inheritance PASSED
test_L00_02_exception.py::TestL00Exception::TestPatchUserExc::test_patch_user_exc PASSED
test_L00_02_exception.py::TestL00Exception::TestPatchUserExc::test_patch_user_exc_force PASSED
test_L00_02_exception.py::TestL00Exception::TestPatchSystemExc::test_patch_system_exc PASSED
test_L00_02_exception.py::TestL00Exception::TestIsUserExc::test_is_user_exc_true PASSED
test_L00_02_exception.py::TestL00Exception::TestIsUserExc::test_is_user_exc_false PASSED
test_L00_02_exception.py::TestL00Exception::TestIsSystemExc::test_is_system_exc_true PASSED
test_L00_02_exception.py::TestL00Exception::TestIsSystemExc::test_is_system_exc_false PASSED
test_L00_02_exception.py::TestL00Exception::TestExceptionGroup::test_init PASSED
test_L00_02_exception.py::TestL00Exception::TestExceptionGroup::test_str PASSED
test_L00_02_exception.py::TestL00Exception::TestExceptionGroup::test_split PASSED

============================== 30 passed in 3.20s ==============================
```

## Mojo Test Results

### Test Command

```bash
mojo run -I . tests/mojo_test_rqmojo/L00_leaf/test_L00_02_exception.mojo
```

### Test Statistics

| Metric | Value |
|--------|-------|
| Test Cases | 37 |
| Passed | 37 |
| Failed | 0 |
| Execution Time | < 1s |

### Test Output

```
============================================================
L00_02_exception Module Tests
============================================================
PASS: CustomError.create msg
PASS: CustomError.create exc_type_name
PASS: CustomError.create error_type
PASS: CustomError.__str__ returns non-empty string
PASS: RQUserError.create message
PASS: RQUserError.create error_type
PASS: RQUserError.__str__
PASS: RQUserError.to_error returns Error
PASS: RQInvalidArgument.create message
PASS: RQInvalidArgument.__str__
PASS: RQInvalidArgument.to_error returns Error
PASS: RQTypeError.create message
PASS: RQTypeError.__str__
PASS: RQTypeError.to_error returns Error
PASS: RQApiNotSupportedError.create message
PASS: RQApiNotSupportedError.__str__
PASS: RQApiNotSupportedError.to_error returns Error
PASS: RQDatacVersionTooLow.create message
PASS: RQDatacVersionTooLow.__str__
PASS: RQDatacVersionTooLow.to_error returns Error
PASS: InstrumentNotFound.create message
PASS: InstrumentNotFound.__str__
PASS: InstrumentNotFound.to_error returns Error
PASS: EnvironmentNotInitialized.create message
PASS: EnvironmentNotInitialized.__str__
PASS: EnvironmentNotInitialized.to_error returns Error
PASS: patch_user_exc returns USER_EXC for NOTSET
PASS: patch_user_exc keeps existing type
PASS: patch_system_exc returns SYSTEM_EXC for NOTSET
PASS: patch_system_exc keeps existing type
PASS: is_user_exc returns True for USER_EXC
PASS: is_user_exc returns False for SYSTEM_EXC
PASS: is_user_exc returns False for NOTSET
PASS: is_system_exc returns True for SYSTEM_EXC
PASS: is_system_exc returns False for USER_EXC
PASS: is_system_exc returns False for NOTSET
PASS: RQUserError message equality
============================================================
Results: 37/37 tests passed
============================================================
```

## Test Coverage

### Exception Classes Tested

| Class | Python | Mojo | Behavior Match |
|-------|--------|------|----------------|
| CustomError | Yes | Yes | Yes |
| CustomException | Yes | N/A | - |
| RQUserError | Yes | Yes | Yes |
| RQInvalidArgument | Yes | Yes | Yes |
| RQTypeError | Yes | Yes | Yes |
| RQApiNotSupportedError | Yes | Yes | Yes |
| RQDatacVersionTooLow | Yes | Yes | Yes |
| InstrumentNotFound | Yes | Yes | Yes |
| EnvironmentNotInitialized | Yes | Yes | Yes |
| ExceptionGroup | Yes | N/A | - |

### Helper Functions Tested

| Function | Python | Mojo | Behavior Match |
|----------|--------|------|----------------|
| patch_user_exc | Yes | Yes | Yes |
| patch_system_exc | Yes | Yes | Yes |
| is_user_exc | Yes | Yes | Yes |
| is_system_exc | Yes | Yes | Yes |

## Verification

- [x] Python tests pass
- [x] Mojo tests pass
- [x] Exception classes work correctly
- [x] Helper functions work correctly
- [x] Error types are properly set

## Conclusion

**L00-02 exception module test PASSED**

All exception classes and helper functions in the exception module have been verified to work correctly in both Python and Mojo implementations.
