from rqmojo.const import SIDE

fn main() raises:
    var buy = SIDE.BUY()
    print(buy.name)
    print(buy.value)
    
    if buy.name == "BUY":
        print("Name test passed")
    else:
        print("Name test failed")
    
    if buy.value == "BUY":
        print("Value test passed")
    else:
        print("Value test failed")
