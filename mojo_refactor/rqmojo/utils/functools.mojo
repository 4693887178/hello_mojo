"""
RQAlpha Mojo - Function Tools
Ported from rqalpha/utils/functools.py
"""


@fieldwise_init
struct CachedFunc(Movable):
    var cache: Dict[String, String]
    var max_size: Int


fn memoize[T](func: String) -> T:
    return None


@fieldwise_init
struct LazyProperty(Movable):
    var name: String
    var cached: Bool


fn lazy_property[T](name: String) -> T:
    return None
