"""
RQAlpha Mojo - API Registration
Ported from rqalpha/api.py
"""

# In Python, this module handles dynamic API registration and decoration.
# In Mojo, we might need a different approach, possibly a compile-time registry or just manual re-exports.
# For now, we provide the interface.

def export_as_api(name: String) -> None:
    """
    Export a function as an API.
    """
    # In Mojo, we can't easily modify the global namespace of the importer.
    # This might need to be handled by the strategy loader or execution context.
    pass

def register_api(name: String, func_name: String) -> None:
    """
    Register a function as an API with a specific name.
    """
    pass

def decorate_api_exc(func_name: String) -> None:
    """
    Decorate a function to handle API exceptions.
    """
    pass
