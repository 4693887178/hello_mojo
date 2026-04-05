from std.collections import Dict, List
from rqmojo.utils import RqValue, KIND_DICT


def deep_update(from_dict: Dict[String, RqValue], mut to_dict: Dict[String, RqValue]) raises:
    for key in from_dict:
        if key in to_dict:
            if to_dict[key].is_dict() and from_dict[key].is_dict():
                deep_update(from_dict[key].dict_val, to_dict[key].dict_val)
            else:
                to_dict[key] = from_dict[key].copy()
        else:
            to_dict[key] = from_dict[key].copy()
