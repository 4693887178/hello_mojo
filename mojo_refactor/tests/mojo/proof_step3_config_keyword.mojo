"""Proof step 3: Import from 'config' module (keyword test)."""
from rqmojo.utils.config import test_config_func

def main():
    var result = test_config_func()
    print("config import result: ", result)
