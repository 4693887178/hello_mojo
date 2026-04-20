"""Proof step 2b: Try importing a FUNCTION (not struct) from rqconfig."""
from rqmojo.utils.rqconfig import parse_config

def main():
    print("SUCCESS: parse_config imported from rqconfig!")
    print("  -> rqconfig module name WORKS for functions")
