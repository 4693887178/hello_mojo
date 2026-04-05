from std.collections import Dict, List
from rqmojo.utils import RqValue, KIND_DICT


def deep_update(from_dict: Dict[String, RqValue], mut to_dict: Dict[String, RqValue]) raises:
    for key in from_dict:
        var value = from_dict[key].copy()
        if key in to_dict:
            if to_dict[key].is_dict() and value.is_dict():
                deep_update(value.dict_val, to_dict[key].dict_val)
            else:
                to_dict[key] = value.copy()
        else:
            to_dict[key] = value.copy()
