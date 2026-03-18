"""
RQAlpha Mojo - Deprecated Functions
Ported from rqalpha/data/base_data_source/deprecated.py
"""


fn deprecated_get_price(order_book_id: String, dt: String) -> Float64:
    return 0.0


fn deprecated_get_volume(order_book_id: String, dt: String) -> Int:
    return 0


@fieldwise_init
struct DeprecatedWarning(Movable):
    var function_name: String
    var message: String
    var since_version: String
    var removed_in_version: String


fn warn_deprecated(warning: DeprecatedWarning) -> None:
    print("DeprecationWarning: " + warning.function_name + " is deprecated since version " + warning.since_version + ". " + warning.message)
