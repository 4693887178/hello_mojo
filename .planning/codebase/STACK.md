# Technology Stack

**Analysis Date:** 2026-03-26

## Languages

**Primary:**
- Mojo 0.26.2.0 - Main implementation language for RQMojo refactoring

**Secondary:**
- Python 3.14 - Original rqalpha source code, used for reference and interop
- Used via Python interop for accessing existing Python libraries

## Runtime

**Environment:**
- Mojo SDK 0.26.2.0
- UV package manager for both Python and Mojo

**Package Manager:**
- UV (Python 3.14 and Mojo 0.26.2.0)
- Virtual environment: `/home/zhou/hello_mojo/trae_cn_78/.venv/`

## Frameworks

**Core:**
- RQAlpha (Python) - Original quantitative trading framework being ported
- Location: `/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages/rqalpha`

**Testing:**
- Mojo built-in testing (no external framework)
- Test files use `def main()` pattern

**Build/Dev:**
- Mojo compiler (`mojo build`, `mojo run`)
- Requires multiple `-I` paths for third-party packages

## Key Dependencies

**Third-Party Mojo Packages (in `rqmojo/third_party/`):**
- **argmojo** - Command-line argument parsing (CLI functionality)
- **EmberJson** - JSON parsing and serialization
- **NuMojo** - NumPy-style numerical computing (NDArray, linear algebra)
- **mojo-yaml** - YAML configuration file parsing
- **morrow** - Date/time handling and timezone support

**Critical:**
- `std.collections` - Dict, List, Set, Optional (standard library)
- `std.python` - Python interop (Python, PythonObject)

## Configuration

**Environment:**
- Python interop requires:
  ```bash
  export LD_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so
  export PYTHONPATH=/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages
  ```

**Build:**
- Multiple include paths required:
  ```bash
  mojo build -I rqmojo/third_party/argmojo/src \
             -I rqmojo/third_party/EmberJson \
             -I rqmojo/third_party/NuMojo \
             -I rqmojo/third_party/mojo-yaml/src \
             -I rqmojo/third_party/morrow.mojo
  ```

## Platform Requirements

**Development:**
- Linux x86_64
- Mojo SDK 0.26.2.0
- Python 3.14 with libpython shared library

**Production:**
- Same as development (native Mojo compilation)

## Version Info

**RQMojo Version:** 0.1.0
- Defined in `rqmojo/_version.mojo`
- `Version.MAJOR = 0`, `Version.MINOR = 1`, `Version.PATCH = 0`

---

*Stack analysis: 2026-03-26*
