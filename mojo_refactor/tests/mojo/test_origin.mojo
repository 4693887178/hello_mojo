from std.memory import UnsafePointer, alloc

def main() raises:
    var ptr = alloc[Int](10)
    print("ptr type test")
