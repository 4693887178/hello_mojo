# External Integrations

**Analysis Date:** 2026-03-26

## APIs & External Services

**RQDatac (Remote Data):**
- Purpose: Remote market data service
- Status: Integration stub exists, not fully implemented
- Config: `rqdatac_uri` parameter in configuration
- Files: `rqmojo/apis/api_rqdatac.mojo`

**Python Interop:**
- Purpose: Access Python libraries and original rqalpha code
- SDK: `std.python` module
- Auth: Environment variables (LD_PRELOAD, PYTHONPATH)

## Data Storage

**Databases:**
- HDF5 format for data bundles
- Location: `~/.rqalpha/bundle/` (default)
- Client: Custom HDF5 reader in `rqmojo/data/base_data_source/h5_reader.mojo`

**File Storage:**
- Local filesystem for:
  - Strategy files
  - Configuration files (YAML)
  - Data bundles (HDF5)
  - Test results (Markdown)

**Caching:**
- DataProxy caching (stub implementation)
- Files: `rqmojo/data/data_proxy.mojo`

## Authentication & Identity

**Auth Provider:**
- Not applicable (local backtesting framework)

## Monitoring & Observability

**Error Tracking:**
- Custom exception handling in `rqmojo/utils/exception.mojo`
- Exception types: CustomError, RQUserError, RQInvalidArgument, etc.

**Logs:**
- Custom logging system: `rqmojo/utils/logger.mojo`
- Log levels: DEBUG, INFO, WARNING, ERROR
- Log capture for testing: `rqmojo/utils/log_capture.mojo`

## CI/CD & Deployment

**Hosting:**
- Local execution only (backtesting framework)

**CI Pipeline:**
- Not configured (manual testing)

## Environment Configuration

**Required env vars:**
```bash
LD_PRELOAD=/path/to/libpython3.14.so  # Python interop
PYTHONPATH=/path/to/python/site-packages  # Python module path
```

**Secrets location:**
- Not applicable (no secrets in backtesting)

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None

## Python Interop Details

**Key Integration Points:**
- `std.python.Python` - Python interpreter access
- `std.python.PythonObject` - Generic Python object wrapper
- Used for:
  - Loading Python strategies
  - Accessing Python libraries not yet ported
  - Testing against original rqalpha behavior

**Interop Pattern:**
```mojo
from std.python import Python, PythonObject

# Convert Python object to Mojo
var py_int = Int(py=python_obj)

# String slicing
var slice = str[byte=0:n]  # Not str[:n]
```

---

*Integration audit: 2026-03-26*
