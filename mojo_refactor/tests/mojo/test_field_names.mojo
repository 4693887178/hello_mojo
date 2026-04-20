from rqmojo.const import EXECUTION_PHASE
from std.reflection import struct_field_count, struct_field_names

fn main():
    comptime field_count = struct_field_count[EXECUTION_PHASE]()
    comptime field_names = struct_field_names[EXECUTION_PHASE]()
    print("Field count:", field_count)
    print("Field names:", field_names)
