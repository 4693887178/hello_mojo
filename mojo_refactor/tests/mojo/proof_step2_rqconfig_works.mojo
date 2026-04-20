"""Proof step 2: After rename, this should COMPILE and RUN successfully."""
from rqmojo.utils.rqconfig import BaseConfig

def main():
    var b = BaseConfig()
    print("SUCCESS: rqconfig module import works!")
    print("BaseConfig created: start_date=", b.start_date.year)
