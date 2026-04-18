from std.collections import Dict
from rqmojo.utils import RqAttrDict


def deep_update(from_dict: RqAttrDict, mut to_dict: RqAttrDict) raises:
    for key in from_dict.keys():
        if to_dict.contains(key):
            if to_dict[key].has_children() and from_dict[key].has_children():
                deep_update(from_dict[key], to_dict[key])
            else:
                to_dict[key] = from_dict[key]
        else:
            to_dict[key] = from_dict[key]
