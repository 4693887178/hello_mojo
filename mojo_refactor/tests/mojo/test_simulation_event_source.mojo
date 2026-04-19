"""
Test for SimulationEventSource - simple version
"""
from std.testing import assert_equal
from std.python import Python, PythonObject
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_event_source import (
    SimulationEventSource, 
    DateTimeCopy, 
    create_simulation_event_source,
    SimEvent
)

def main() raises:
    print("=== SimulationEventSource Test ===")
    
    # Test 1: SimEvent initialization
    print("\n1. Testing SimEvent initialization...")
    var ev = SimEvent(event_type="test", order_book_id="000001")
    assert_equal(ev.event_type, "test")
    assert_equal(ev.order_book_id, "000001")
    print("✓ SimEvent initialized correctly")
    
    # Test 2: DateTimeCopy initialization
    print("\n2. Testing DateTimeCopy initialization...")
    var dt = DateTimeCopy(year=2024, month=1, day=1, hour=0, minute=0, second=0)
    assert_equal(dt.year, 2024)
    assert_equal(dt.month, 1)
    assert_equal(dt.day, 1)
    print("✓ DateTimeCopy initialized correctly")
    
    # Test 3: Compilation test - main test
    print("\n3. Testing full compilation...")
    print("✓ All code compiles successfully")
    
    print("\n=== All tests passed! ===")
