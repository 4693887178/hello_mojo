from std.utils import StaticTuple

struct Foo(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String

    fn __init__(out self, name: String, value: String):
        self.name = name
        self.value = value

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.name, "=", self.value)

fn main():
    alias a = Foo("A", "val_a")
    alias b = Foo("B", "val_b")
    alias c = Foo("C", "val_c")

    alias items = StaticTuple[Foo, 3](a, b, c)

    print(items[0])
    print(items[1])
    print(items[2])

    print("=== reversed ===")
    for i in range(3):
        print(items[2-i])
