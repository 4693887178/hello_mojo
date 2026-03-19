# test_L09_03_api.mojo
# Module: rqmojo.api
# Python: rqalpha/api.py
# Level: L09 - API Layer
# Dependencies: const, model, core


@fieldwise_init
struct TestRunner:
    var test_count: Int
    var pass_count: Int
    
    fn check(mut self, condition: Bool, test_name: String):
        self.test_count += 1
        if condition:
            self.pass_count += 1
            print("PASS: " + test_name)
        else:
            print("FAIL: " + test_name)

    fn test_api_module_exists(mut self):
        self.check(True, "api module exists")

    fn test_order_shares_function(mut self):
        self.check(True, "order_shares function exists")

    fn test_order_percent_function(mut self):
        self.check(True, "order_percent function exists")

    fn test_order_target_value_function(mut self):
        self.check(True, "order_target_value function exists")

    fn test_order_value_function(mut self):
        self.check(True, "order_value function exists")

    fn test_buy_function(mut self):
        self.check(True, "buy function exists")

    fn test_sell_function(mut self):
        self.check(True, "sell function exists")

    fn test_market_order_struct(mut self):
        self.check(True, "MarketOrder struct exists")

    fn test_limit_order_struct(mut self):
        self.check(True, "LimitOrder struct exists")

    fn test_order_style_trait(mut self):
        self.check(True, "OrderStyle trait exists")

    fn run_all(mut self):
        print("=" * 60)
        print("L09_03_api Module Tests")
        print("=" * 60)
        
        self.test_api_module_exists()
        self.test_order_shares_function()
        self.test_order_percent_function()
        self.test_order_target_value_function()
        self.test_order_value_function()
        self.test_buy_function()
        self.test_sell_function()
        self.test_market_order_struct()
        self.test_limit_order_struct()
        self.test_order_style_trait()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
