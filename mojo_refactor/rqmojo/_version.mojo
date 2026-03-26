"""
RQAlpha Mojo - Version Information
Ported from rqalpha/_version.py
"""

from std.collections import List


struct Version:
    comptime MAJOR: Int = 0
    comptime MINOR: Int = 1
    comptime PATCH: Int = 0
    comptime VERSION: String = "0.1.0"


def get_version() -> String:
    return Version.VERSION


comptime __version__: String = "0.1.0"
comptime version: String = __version__


comptime __all__: List[String] = [
    "__version__",
    "version",
    "get_version",
    "Version",
]
