from std.collections import Dict
from rqmojo.utils import RqValue, KIND_DICT


fn deep_update(from_dict: Dict[String, RqValue], mut to_dict: Dict[String, RqValue]) raises:
    for k in from_dict.keys():
        var value = from_dict[k].copy()
        if to_dict.__contains__(k):
            var to_value = to_dict[k].copy()
            if to_value.kind == KIND_DICT and value.kind == KIND_DICT:
                deep_update(value.dict_val, to_value.dict_val)
                to_dict[k] = to_value.copy()
            else:
                to_dict[k] = value.copy()
        else:
            to_dict[k] = value.copy()
