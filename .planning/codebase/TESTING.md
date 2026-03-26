# Testing Patterns

**Analysis Date:** 2026-03-26

## Test Framework

**Runner:**
- Mojo built-in testing (no external framework)
- Tests are run with `mojo run <test_file>.mojo`

**Assertion Library:**
- Manual assertions using `if` statements and `print`
- Custom assertion helpers in `rqmojo/utils/testing/`

**Run Commands:**
```bash
# Run single test
mojo run -I . tests/mojo/utils/test_logger.mojo

# Run with Python interop
LD_PRELOAD=/path/to/libpython3.14.so \
PYTHONPATH=/path/to/site-packages \
mojo run -I . tests/mojo/utils/test_typing.mojo
```

## Test File Organization

**Location:**
- Separate test directory: `tests/mojo/`
- Mirrors source structure: `tests/mojo/utils/` for `rqmojo/utils/`

**Naming:**
- Pattern: `test_<module_name>.mojo`
- Examples: `test_logger.mojo`, `test_typing.mojo`

**Structure:**
```
tests/
├── mojo/                      # Mojo tests
│   ├── model/
│   │   └── test_model_init.mojo
│   ├── utils/
│   │   ├── test_logger.mojo
│   │   ├── test_typing.mojo
│   │   └── test_exception_standalone.mojo
│   └── third_party/
│       └── morrow/
│           └── test.mojo
└── python/                    # Python comparison tests
```

## Test Structure

**Suite Organization:**
```mojo
"""
Test for <module name>
"""

from std.collections import Dict, List
from rqmojo.utils.logger import init_logger, user_log

def test_<feature>() raises:
    # Setup
    init_logger()
    
    # Execute
    var result = some_function()
    
    # Assert
    if result != expected:
        print("FAIL: test_<feature>")
        print("Expected: " + expected)
        print("Got: " + result)
    else:
        print("PASS: test_<feature>")

def main() raises:
    test_<feature>()
    print("All tests passed!")
```

**Patterns:**
- Setup: Initialize required components
- Execute: Call the function under test
- Assert: Manual comparison and print results

## Mocking

**Framework:** Custom mocking utilities

**Patterns:**
```mojo
from rqmojo.utils.testing.mocking import MockFactory

# Create mock objects
var mock_env = MockFactory.create_environment()
var mock_data_proxy = MockFactory.create_data_proxy()
```

**What to Mock:**
- Environment for integration tests
- DataProxy for data-dependent tests
- External services (Python interop)

**What NOT to Mock:**
- Pure data structures (structs)
- Utility functions
- Simple transformations

## Fixtures and Factories

**Test Data:**
```mojo
from rqmojo.utils.testing.fixtures import create_test_config

def test_with_fixture() raises:
    var config = create_test_config()
    # Use config in test
```

**Location:**
- `rqmojo/utils/testing/fixtures.mojo`
- `rqmojo/utils/testing/mocking.mojo`
- `rqmojo/utils/testing/integration.mojo`

## Coverage

**Requirements:** No formal coverage requirement

**Coverage Approach:**
- Manual coverage tracking
- Test result files in `tests/results/`

## Test Types

**Unit Tests:**
- Test individual functions and structs
- Location: `tests/mojo/<module>/test_<name>.mojo`
- Focus: Pure logic, no external dependencies

**Integration Tests:**
- Test component interactions
- Location: `rqmojo/utils/testing/integration.mojo`
- Focus: Environment, data flow, mod interactions

**E2E Tests:**
- Run complete backtests with example strategies
- Location: `rqmojo/examples/`
- Focus: Full system behavior

## Common Patterns

**Testing Exceptions:**
```mojo
def test_exception():
    var caught = False
    try:
        raise_error_function()
    except:
        caught = True
    
    if not caught:
        print("FAIL: Expected exception not raised")
```

**Testing with Python Interop:**
```mojo
def test_python_interop():
    # Requires LD_PRELOAD and PYTHONPATH
    from std.python import Python
    
    var py = Python()
    # Test Python interop functionality
```

**Async Testing:**
- Not applicable (no async in current implementation)

## Test Utilities

**Available Utilities:**
- `MockFactory` - Create mock objects
- `create_test_config()` - Create test configurations
- `LogCapture` - Capture log output for testing
- `IntegrationTestRunner` - Run integration tests

**Location:**
- `rqmojo/utils/testing/__init__.mojo`
- `rqmojo/utils/testing/fixtures.mojo`
- `rqmojo/utils/testing/mocking.mojo`
- `rqmojo/utils/log_capture.mojo`

## Running Tests

**Single Test:**
```bash
mojo run -I rqmojo tests/mojo/utils/test_logger.mojo
```

**With Third-Party Dependencies:**
```bash
mojo run -I rqmojo \
         -I rqmojo/third_party/argmojo/src \
         -I rqmojo/third_party/EmberJson \
         -I rqmojo/third_party/NuMojo \
         -I rqmojo/third_party/mojo-yaml/src \
         -I rqmojo/third_party/morrow.mojo \
         tests/mojo/<path>/test_<name>.mojo
```

**With Python Interop:**
```bash
LD_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so \
PYTHONPATH=/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages \
mojo run -I rqmojo tests/mojo/utils/test_typing.mojo
```

---

*Testing analysis: 2026-03-26*
