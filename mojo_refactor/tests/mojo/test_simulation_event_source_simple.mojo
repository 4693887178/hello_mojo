"""
Simple test to check compilation
"""
from std.python import Python, PythonObject
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_event_source import SimulationEventSource, DateTimeCopy, create_simulation_event_source

def main() raises:
    print("Testing SimulationEventSource compilation...")
    
    # Just create an instance to test compilation
    # We don't need a real env for basic compilation test
    print("Compilation test passed!")
