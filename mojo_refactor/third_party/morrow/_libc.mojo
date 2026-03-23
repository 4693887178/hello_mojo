from std.memory.unsafe_pointer import UnsafePointer
from std.ffi import external_call, c_int, c_long
from std.memory.pointer import Pointer

comptime c_void = UInt8
comptime c_char = UInt8
comptime c_schar = Int8
comptime c_uchar = UInt8
comptime c_short = Int16
comptime c_ushort = UInt16
comptime c_uint = UInt32
comptime c_ulong = UInt64
comptime c_float = Float32
comptime c_double = Float64


@fieldwise_init
struct CTimeval(TrivialRegisterPassable):
    var tv_sec: Int
    var tv_usec: Int


@fieldwise_init
struct CTm(TrivialRegisterPassable):
    var tm_sec: c_int
    var tm_min: c_int
    var tm_hour: c_int
    var tm_mday: c_int
    var tm_mon: c_int
    var tm_year: c_int
    var tm_wday: c_int
    var tm_yday: c_int
    var tm_isdst: c_int
    var tm_gmtoff: c_long


@always_inline
def c_gettimeofday() -> CTimeval:
    var tv = CTimeval(0, 0)
    external_call["gettimeofday", NoneType](Pointer(to=tv), 0)
    return tv


@always_inline
def c_localtime(tv_sec: Int) -> CTm:
    var tm = CTm(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    var mut_tv_sec = tv_sec
    _ = external_call["localtime_r", Pointer[CTm, MutAnyOrigin]](
        Pointer(to=mut_tv_sec), Pointer(to=tm)
    )
    return tm


@always_inline
def c_strptime(time_str: String, time_format: String) -> CTm:
    var tm = CTm(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    _ = external_call["strptime", Pointer[CTm, MutAnyOrigin]](
        time_str.unsafe_ptr(), time_format.unsafe_ptr(), Pointer(to=tm)
    )
    return tm


@always_inline
def c_gmtime(tv_sec: Int) -> CTm:
    var tm = CTm(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    var mut_tv_sec = tv_sec
    _ = external_call["gmtime_r", Pointer[CTm, MutAnyOrigin]](
        Pointer(to=mut_tv_sec), Pointer(to=tm)
    )
    return tm


def to_char_ptr(s: String) -> UnsafePointer[c_char]:
    var ptr = UnsafePointer[c_char]().alloc(len(s))
    for i in range(len(s)):
        ptr.store(i, ord(s[i]))
    return ptr
