"""Proof step 1: This will FAIL to compile because 'config' is reserved."""
from rqmojo.utils.config import BaseConfig

def main():
    var b = BaseConfig()
    print("UNEXPECTED: config import succeeded!")
