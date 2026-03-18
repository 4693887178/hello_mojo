"""
RQAlpha Mojo - Dictionary Functions
Ported from rqalpha/utils/dict_func.py
Uses Mojo traits similar to C++ concepts
"""

from collections import Dict


trait Mapping:
    comptime KeyType: Copyable & Hashable & Equatable
    comptime ValueType: Movable & ImplicitlyDestructible
    fn keys(self) -> List[Self.KeyType]: ...
    fn __contains__(self, key: Self.KeyType) -> Bool: ...
    fn __getitem__(self, key: Self.KeyType) -> Self.ValueType: ...
    fn __setitem__(mut self, key: Self.KeyType, value: Self.ValueType): ...


trait NestedMapping:
    comptime KeyType: Copyable & Hashable & Equatable
    comptime ValueType: Mapping
    fn keys(self) -> List[Self.KeyType]: ...
    fn __contains__(self, key: Self.KeyType) -> Bool: ...
    fn __getitem__(self, key: Self.KeyType) -> Self.ValueType: ...
    fn __setitem__(mut self, key: Self.KeyType, value: Self.ValueType): ...


fn deep_update[M: Mapping](from_dict: M, mut to_dict: M) -> None:
    for key in from_dict.keys():
        var value = from_dict[key]
        to_dict[key] = value^


fn deep_update[N: NestedMapping](from_dict: N, mut to_dict: N) -> None:
    for key in from_dict.keys():
        var value = from_dict[key]
        if to_dict.__contains__(key):
            deep_update(value, to_dict[key])
        else:
            to_dict[key] = value^
