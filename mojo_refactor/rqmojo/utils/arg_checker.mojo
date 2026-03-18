"""
RQAlpha Mojo - Argument Checker
Ported from rqalpha/utils/arg_checker.py
"""


fn check_string(value: String, name: String) raises -> Bool:
    if len(value) == 0:
        raise Error("Argument '" + name + "' cannot be empty string")
    return True


fn check_int(value: Int, name: String, min_val: Int = 0, max_val: Int = 999999999) raises -> Bool:
    if value < min_val:
        raise Error("Argument '" + name + "' must be >= " + String(min_val))
    if value > max_val:
        raise Error("Argument '" + name + "' must be <= " + String(max_val))
    return True


fn check_float(value: Float64, name: String, min_val: Float64 = 0.0, max_val: Float64 = 1e12) raises -> Bool:
    if value < min_val:
        raise Error("Argument '" + name + "' must be >= " + String(min_val))
    if value > max_val:
        raise Error("Argument '" + name + "' must be <= " + String(max_val))
    return True


fn check_percentage(value: Float64, name: String) raises -> Bool:
    if value < 0.0 or value > 1.0:
        raise Error("Argument '" + name + "' must be between 0 and 1")
    return True


fn check_order_book_id(value: String, name: String) raises -> Bool:
    if len(value) == 0:
        raise Error("Argument '" + name + "' cannot be empty")
    if value.find(".") < 0:
        raise Error("Argument '" + name + "' must be in format 'CODE.EXCHANGE'")
    return True
