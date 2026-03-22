"""
RQAlpha Mojo - Version Information
"""

struct Version:
    comptime MAJOR: Int = 0
    comptime MINOR: Int = 1
    comptime PATCH: Int = 0
    comptime VERSION: String = "0.1.0"


def get_version() -> String:
    return Version.VERSION


comptime __version__: String = "0.1.0"
