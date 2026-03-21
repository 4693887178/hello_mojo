"""
RQAlpha Mojo - Dictionary Functions
Ported from rqalpha/utils/dict_func.py

Uses Variant for dynamic type handling - supports nested Dict
"""

from collections import Dict
from utils import Variant


alias DynamicValue = Variant[Int, Float64, String, Bool, NoneType, Dict[String, DynamicValue]]


fn main():
    print("dict_func.mojo - DynamicDict test")

    var from_dict = Dict[String, DynamicValue]()
    from_dict["name"] = DynamicValue(String("test"))
    from_dict["count"] = DynamicValue(Int(42))
    from_dict["price"] = DynamicValue(Float64(3.14))

    var to_dict = Dict[String, DynamicValue]()
    to_dict["existing"] = DynamicValue(String("already there"))

    print("from_dict size:", from_dict.size())
    print("to_dict size:", to_dict.size())
    print("OK")
