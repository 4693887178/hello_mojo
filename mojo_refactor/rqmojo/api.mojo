"""
RQAlpha Mojo - API Registration
Ported from rqalpha/api.py
"""

from collections import List


var __all__: List[String] = List[String]()


def decorate_api_exc(func: FunctionType) -> FunctionType:
    """
    Decorate a function to handle API exceptions.
    In Mojo, we provide a simplified version that wraps the function.
    """
    return func


def register_api(name: String, func: FunctionType) -> None:
    """
    Register a function as an API with a specific name.
    """
    __all__.append(name)


def export_as_api(func: FunctionType, name: String = "") -> FunctionType:
    """
    Export a function as an API.
    """
    var api_name = name
    if api_name == "":
        api_name = "api_func"
    
    __all__.append(api_name)
    return decorate_api_exc(func)
