# json_parser.mojo
# Simple JSON parser for test data

from std.collections import Dict


@fieldwise_init
struct JSONValue(Copyable, Movable):
    var string_value: String
    var int_value: Int
    var float_value: Float64
    var bool_value: Bool
    var value_type: String  # "string", "int", "float", "bool", "null"
    
    def get_string(self) -> String:
        return self.string_value
    
    def get_int(self) -> Int:
        return self.int_value
    
    def get_float(self) -> Float64:
        return self.float_value
    
    def get_bool(self) -> Bool:
        return self.bool_value


def create_json_string(s: String) -> JSONValue:
    return JSONValue(string_value=s, int_value=0, float_value=0.0, bool_value=False, value_type="string")

def create_json_int(i: Int) -> JSONValue:
    return JSONValue(string_value="", int_value=i, float_value=0.0, bool_value=False, value_type="int")

def create_json_float(f: Float64) -> JSONValue:
    return JSONValue(string_value="", int_value=0, float_value=f, bool_value=False, value_type="float")

def create_json_bool(b: Bool) -> JSONValue:
    return JSONValue(string_value="", int_value=0, float_value=0.0, bool_value=b, value_type="bool")

def create_json_null() -> JSONValue:
    return JSONValue(string_value="", int_value=0, float_value=0.0, bool_value=False, value_type="null")


def string_contains_dot(s: String) -> Bool:
    for i in range(len(s)):
        if s[i:i+1] == ".":
            return True
    return False


def parse_simple_json_string(json_str: String) raises -> Dict[String, JSONValue]:
    var result = Dict[String, JSONValue]()
    
    var in_object = False
    var in_string = False
    var in_key = False
    var in_value = False
    var current_key = ""
    var current_value = ""
    var escape_next = False
    
    for i in range(len(json_str)):
        var c = json_str[i:i+1]
        
        if escape_next:
            current_value = current_value + c
            escape_next = False
            continue
        
        if c == "\\":
            escape_next = True
            continue
        
        if c == "{" and not in_string:
            in_object = True
            continue
        
        if c == "}" and not in_string:
            in_object = False
            if len(current_key) > 0 and len(current_value) > 0:
                result[current_key] = parse_json_value(current_value)
            break
        
        if c == "\"" and not in_value:
            if not in_string:
                in_string = True
                if len(current_key) == 0:
                    in_key = True
                else:
                    in_value = True
            else:
                in_string = False
                if in_key:
                    in_key = False
                elif in_value:
                    in_value = False
            continue
        
        if in_string:
            if in_key:
                current_key = current_key + c
            elif in_value:
                current_value = current_value + c
            continue
        
        if c == ":" and not in_string:
            continue
        
        if c == "," and not in_string:
            if len(current_key) > 0 and len(current_value) > 0:
                result[current_key] = parse_json_value(current_value)
            current_key = ""
            current_value = ""
            continue
        
        if not in_string and in_object and len(current_key) > 0:
            current_value = current_value + c
    
    return result^


def parse_json_value(value_str: String) raises -> JSONValue:
    var trimmed = value_str.strip()
    
    if trimmed == "null":
        return create_json_null()
    
    if trimmed == "true":
        return create_json_bool(True)
    
    if trimmed == "false":
        return create_json_bool(False)
    
    if len(trimmed) >= 2 and trimmed[0:1] == "\"" and trimmed[len(trimmed)-1:len(trimmed)] == "\"":
        var result_str = String(trimmed[1:len(trimmed)-1])
        return create_json_string(result_str)
    
    var trimmed_str = String(trimmed)
    if string_contains_dot(trimmed_str):
        return create_json_float(Float64(trimmed_str))
    
    return create_json_int(Int(trimmed_str))
