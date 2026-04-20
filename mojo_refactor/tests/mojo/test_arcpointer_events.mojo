from std.collections import List, Dict
from std.memory import ArcPointer


struct Counter(Movable):
    var value: Int

    def __init__(out self):
        self.value = 0

    def increment(mut self):
        self.value += 1


@fieldwise_init
struct SimpleEvent(Copyable, Movable, Writable):
    var name: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("SimpleEvent(", self.name, ")")


struct ConcreteListener(Movable):
    var name: String
    var counter: ArcPointer[Counter]

    def __init__(out self, name: String, counter: ArcPointer[Counter]):
        self.name = name
        self.counter = counter

    def handle(mut self, event: SimpleEvent) -> Bool:
        self.counter[].increment()
        print(self.name, " handled ", event.name, " counter=", self.counter[].value)
        return False


def test_arcpointer_in_list() raises:
    print("=== Test 1: ArcPointer can be stored in List ===")
    var counter = ArcPointer(Counter())
    print("initial counter:", counter[].value)

    var listeners = List[ArcPointer[ConcreteListener]]()
    listeners.append(ArcPointer(ConcreteListener(name="listener_a", counter=counter.copy())))
    listeners.append(ArcPointer(ConcreteListener(name="listener_b", counter=counter.copy())))

    for listener in listeners:
        listener[].handle(SimpleEvent(name="test_event"))

    print("final counter (should be 2):", counter[].value)


def test_arcpointer_copy_shares_state() raises:
    print("\n=== Test 2: ArcPointer.copy() shares the same underlying object ===")
    var counter = ArcPointer(Counter())
    var counter2 = counter.copy()
    counter[].increment()
    print("counter.value after incrementing original:", counter[].value)
    print("counter2.value (should be same, 1):", counter2[].value)
    counter2[].increment()
    print("counter.value after incrementing copy:", counter[].value)
    print("counter2.value (should be same, 2):", counter2[].value)


def test_arcpointer_in_dict() raises:
    print("\n=== Test 3: ArcPointer in Dict (event bus pattern) ===")
    var counter = ArcPointer(Counter())
    var bus: Dict[String, List[ArcPointer[ConcreteListener]]] = Dict[String, List[ArcPointer[ConcreteListener]]]()

    bus["BAR"] = List[ArcPointer[ConcreteListener]]()
    bus["BAR"].append(ArcPointer(ConcreteListener(name="bar_handler_1", counter=counter.copy())))
    bus["BAR"].append(ArcPointer(ConcreteListener(name="bar_handler_2", counter=counter.copy())))

    bus["TICK"] = List[ArcPointer[ConcreteListener]]()
    bus["TICK"].append(ArcPointer(ConcreteListener(name="tick_handler", counter=counter.copy())))

    for listener in bus["BAR"]:
        listener[].handle(SimpleEvent(name="bar_event"))

    for listener in bus["TICK"]:
        listener[].handle(SimpleEvent(name="tick_event"))

    print("total counter (should be 3):", counter[].value)


def main() raises:
    test_arcpointer_in_list()
    test_arcpointer_copy_shares_state()
    test_arcpointer_in_dict()
    print("\n=== All tests passed ===")
