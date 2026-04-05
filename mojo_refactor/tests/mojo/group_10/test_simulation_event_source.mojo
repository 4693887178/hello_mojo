"""
Test for mod/rqmojo_mod_sys_simulation/simulation_event_source.mojo
Group 10 - File 6
"""

from std.collections import Dict, List
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_event_source import (
    SimulationEventSource, Event, create_simulation_event_source, create_simulation_event_source_with_test_data
)
from rqmojo.utils.typing import DateTime, DateTimeDate
from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_event_struct() raises:
    print("Test: Event struct exists")
    var event = Event("BAR", DateTime(2024, 1, 1, 10, 0, 0, 0), DateTime(2024, 1, 1, 10, 0, 0, 0), "000001.XSHE")
    assert_equal(event.event_type, "BAR", "Event type should match")
    print("  PASSED")


def test_simulation_event_source_struct() raises:
    print("Test: SimulationEventSource struct exists")
    var source = create_simulation_event_source(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 1, 31, 23, 59, 59, 0), "1d")
    assert_true(True, "SimulationEventSource should be creatable")
    print("  PASSED")


def test_simulation_event_source_with_test_data() raises:
    print("Test: SimulationEventSource with test data")
    var source = create_simulation_event_source_with_test_data()
    var count = source.events_count()
    assert_true(count > 0, "Should have events")
    print("  PASSED")


def test_simulation_event_source_add_event() raises:
    print("Test: SimulationEventSource add_event")
    var source = create_simulation_event_source(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 1, 31, 23, 59, 59, 0), "1d")
    var initial_count = source.events_count()
    source.add_event(Event("TEST", DateTime(2024, 1, 1, 10, 0, 0, 0), DateTime(2024, 1, 1, 10, 0, 0, 0), ""))
    var new_count = source.events_count()
    assert_equal(new_count, initial_count + 1, "Should have one more event")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
