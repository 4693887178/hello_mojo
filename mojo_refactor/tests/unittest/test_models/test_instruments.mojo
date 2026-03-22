"""
RQAlpha Mojo - Instrument Tests
Ported from tests/unittest/test_models/test_instruments.py
Tests for the Instrument model with Python interop for test data loading
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.python import Python, PythonObject
from rqmojo.const import INSTRUMENT_TYPE, DEFAULT_ACCOUNT_TYPE, EXCHANGE, POSITION_DIRECTION, MARKET
from rqmojo.const import INSTRUMENT_TYPE_CS, INSTRUMENT_TYPE_FUTURE, INSTRUMENT_TYPE_INDX, INSTRUMENT_TYPE_ETF, INSTRUMENT_TYPE_LOF
from rqmojo.const import DEFAULT_ACCOUNT_TYPE_STOCK, DEFAULT_ACCOUNT_TYPE_FUTURE
from rqmojo.const import EXCHANGE_XSHE, EXCHANGE_XSHG
from rqmojo.const import POSITION_DIRECTION_LONG, MARKET_CN
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.utils.datetime_func import DateTime, Date, TimeRange


@fieldwise_init
struct TestResult(Writable, Movable, Copyable):
    var test_name: String
    var passed: Bool
    var message: String
    var python_result: String
    var mojo_result: String
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("TestResult(", self.test_name, ", passed=", self.passed, ")")


struct TestContext:
    var test_results: List[TestResult]
    var instruments: Dict[String, PythonObject]
    var py_instrument: PythonObject
    
    def __init__(out self):
        self.test_results = List[TestResult]()
        self.instruments = Dict[String, PythonObject]()
        self.py_instrument = PythonObject()


def record_result(mut ctx: TestContext, test_name: String, passed: Bool, message: String = "", py_res: String = "", mojo_res: String = ""):
    ctx.test_results.append(TestResult(test_name, passed, message, py_res, mojo_res))


def pad_zero(n: Int) -> String:
    if n < 10:
        return "0" + String(n)
    return String(n)


def py_to_mojo_instrument(py_inst: PythonObject) raises -> Instrument:
    var py_type = String(py_inst.type.name)
    var ins_type = INSTRUMENT_TYPE_CS
    if py_type == "CS":
        ins_type = INSTRUMENT_TYPE_CS
    elif py_type == "FUTURE":
        ins_type = INSTRUMENT_TYPE_FUTURE
    elif py_type == "INDX":
        ins_type = INSTRUMENT_TYPE_INDX
    elif py_type == "ETF":
        ins_type = INSTRUMENT_TYPE_ETF
    elif py_type == "LOF":
        ins_type = INSTRUMENT_TYPE_LOF
    
    var exchange_str = String(py_inst.exchange)
    var exchange = EXCHANGE_XSHE
    if exchange_str == "XSHE":
        exchange = EXCHANGE_XSHE
    elif exchange_str == "XSHG":
        exchange = EXCHANGE_XSHG
    
    var listed_date_str = "1990-01-01"
    var de_listed_date_str = "2999-12-31"
    
    try:
        var py_listed = py_inst.listed_date
        listed_date_str = String(py_listed.year) + "-" + pad_zero(Int(py=py_listed.month)) + "-" + pad_zero(Int(py=py_listed.day))
    except:
        pass
    
    try:
        var py_de_listed = py_inst.de_listed_date
        de_listed_date_str = String(py_de_listed.year) + "-" + pad_zero(Int(py=py_de_listed.month)) + "-" + pad_zero(Int(py=py_de_listed.day))
    except:
        pass
    
    var round_lot = 100
    try:
        round_lot = Int(py=py_inst.round_lot)
    except:
        pass
    
    var contract_multiplier = 1.0
    try:
        contract_multiplier = Float64(py=py_inst.contract_multiplier)
    except:
        pass
    
    return Instrument(
        order_book_id_val=String(py_inst.order_book_id),
        symbol_val=String(py_inst.symbol),
        type_val=ins_type,
        exchange_val=exchange,
        listed_date_str=listed_date_str,
        de_listed_date_str=de_listed_date_str,
        round_lot_val=round_lot,
        contract_multiplier_val=contract_multiplier,
        underlying_symbol_val="",
        market_val=MARKET_CN,
        trading_hours_str=""
    )


def load_test_data(mut ctx: TestContext) raises:
    var pickle = Python.import_module("pickle")
    var os = Python.import_module("os")
    
    var base_dir = "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/unittest/test_models"
    var test_data_path = os.path.join(base_dir, "resources", "test_instruments.pkl")
    
    var path_str = String(test_data_path)
    
    var py_open = Python.import_module("builtins").open
    var f = py_open(path_str, "rb")
    var test_data = pickle.load(f)
    f.close()
    
    ctx.py_instrument = Python.import_module("rqalpha.model.instrument").Instrument
    
    for data in test_data:
        var order_book_id = String(data.get("order_book_id"))
        var mock_getter = Python.evaluate("lambda x: 1.0")
        var py_inst = ctx.py_instrument(data, mock_getter)
        ctx.instruments[order_book_id] = py_inst


def get_instrument(ctx: TestContext, key: String) raises -> PythonObject:
    var opt = ctx.instruments.get(key)
    if opt == None:
        raise Error("Instrument not found: " + key)
    return opt.value()


def test_basic_properties(mut ctx: TestContext) raises:
    var all_passed = True
    var messages = List[String]()
    
    var cs_inst = get_instrument(ctx, "000001.XSHE")
    var mojo_inst = py_to_mojo_instrument(cs_inst)
    
    if mojo_inst.order_book_id() != "000001.XSHE":
        all_passed = False
        messages.append("order_book_id mismatch")
    
    if mojo_inst.symbol() != String(cs_inst.symbol):
        all_passed = False
        messages.append("symbol mismatch")
    
    if mojo_inst.type() != INSTRUMENT_TYPE_CS:
        all_passed = False
        messages.append("type mismatch for CS")
    
    if mojo_inst.round_lot() != Int(py=cs_inst.round_lot):
        all_passed = False
        messages.append("round_lot mismatch")
    
    record_result(ctx, "test_basic_properties_stock", all_passed, ", ".join(messages))
    
    var indx_inst = get_instrument(ctx, "000001.XSHG")
    var mojo_indx = py_to_mojo_instrument(indx_inst)
    
    var passed = mojo_indx.type() == INSTRUMENT_TYPE_INDX
    record_result(ctx, "test_basic_properties_index", passed)
    
    var future_inst = get_instrument(ctx, "A0303")
    var mojo_future = py_to_mojo_instrument(future_inst)
    
    passed = mojo_future.type() == INSTRUMENT_TYPE_FUTURE
    if mojo_future.contract_multiplier() != Float64(py=future_inst.contract_multiplier):
        passed = False
    record_result(ctx, "test_basic_properties_future", passed)


def test_date_properties(mut ctx: TestContext) raises:
    var cs_inst = get_instrument(ctx, "000001.XSHE")
    var mojo_inst = py_to_mojo_instrument(cs_inst)
    
    var py_listed = cs_inst.listed_date
    var mojo_listed = mojo_inst.listed_date()
    
    var year_match = mojo_listed.year == Int(py=py_listed.year)
    var month_match = mojo_listed.month == Int(py=py_listed.month)
    var day_match = mojo_listed.day == Int(py=py_listed.day)
    
    var passed = year_match and month_match and day_match
    var msg = ""
    if not passed:
        msg = "listed_date mismatch"
    
    record_result(ctx, "test_date_properties", passed, msg)


def test_account_type(mut ctx: TestContext) raises:
    var all_passed = True
    var messages = List[String]()
    
    var cs_inst = get_instrument(ctx, "000001.XSHE")
    var mojo_inst = py_to_mojo_instrument(cs_inst)
    
    var py_account_type = cs_inst.account_type
    var mojo_account_type = mojo_inst.account_type()
    
    if String(py_account_type.name) != mojo_account_type.name():
        all_passed = False
        messages.append("CS account_type mismatch")
    
    var future_inst = get_instrument(ctx, "A0303")
    var mojo_future = py_to_mojo_instrument(future_inst)
    
    py_account_type = future_inst.account_type
    mojo_account_type = mojo_future.account_type()
    
    if String(py_account_type.name) != mojo_account_type.name():
        all_passed = False
        messages.append("Future account_type mismatch")
    
    record_result(ctx, "test_account_type", all_passed, ", ".join(messages))


def test_trading_hours(mut ctx: TestContext) raises:
    var cs_inst = get_instrument(ctx, "000001.XSHE")
    var mojo_inst = py_to_mojo_instrument(cs_inst)
    
    var py_hours = cs_inst.trading_hours
    var mojo_hours = mojo_inst.trading_hours()
    
    var py_len = Int(py=len(py_hours))
    var mojo_len = len(mojo_hours)
    
    var passed = py_len == mojo_len
    var msg = ""
    if not passed:
        msg = "trading_hours length mismatch: Python=" + String(py_len) + " Mojo=" + String(mojo_len)
    else:
        if mojo_len >= 1:
            var first = mojo_hours[0]
            if first.start_hour != 9 or first.start_minute != 31:
                passed = False
                msg = "First trading period start mismatch"
    
    record_result(ctx, "test_trading_hours", passed, msg)


def test_round_lot_special_cases(mut ctx: TestContext) raises:
    var all_passed = True
    var messages = List[String]()
    
    var ksh_inst_opt = ctx.instruments.get("688001.XSHG")
    if ksh_inst_opt != None:
        var ksh_inst = ksh_inst_opt.value()
        var mojo_ksh = py_to_mojo_instrument(ksh_inst)
        var py_round_lot = Int(py=ksh_inst.round_lot)
        var mojo_round_lot = mojo_ksh.round_lot()
        
        if py_round_lot != mojo_round_lot:
            all_passed = False
            messages.append("KSH round_lot mismatch")
    
    var mainboard_inst = get_instrument(ctx, "000001.XSHE")
    var mojo_main = py_to_mojo_instrument(mainboard_inst)
    
    var py_round_lot = Int(py=mainboard_inst.round_lot)
    var mojo_round_lot = mojo_main.round_lot()
    
    if py_round_lot != mojo_round_lot:
        all_passed = False
        messages.append("MainBoard round_lot mismatch: Python=" + String(py_round_lot) + " Mojo=" + String(mojo_round_lot))
    
    record_result(ctx, "test_round_lot_special_cases", all_passed, ", ".join(messages))


def test_future_continuous_contract_detection(mut ctx: TestContext) raises:
    var all_passed = True
    var messages = List[String]()
    
    var result1 = ctx.py_instrument.is_future_continuous_contract("A88")
    if not Bool(py=result1):
        all_passed = False
        messages.append("A88 should be continuous contract")
    
    var result2 = ctx.py_instrument.is_future_continuous_contract("IF88")
    if not Bool(py=result2):
        all_passed = False
        messages.append("IF88 should be continuous contract")
    
    var result3 = ctx.py_instrument.is_future_continuous_contract("A99")
    if not Bool(py=result3):
        all_passed = False
        messages.append("A99 should be continuous contract")
    
    var result4 = ctx.py_instrument.is_future_continuous_contract("A2301")
    if Bool(py=result4):
        all_passed = False
        messages.append("A2301 should NOT be continuous contract")
    
    var result5 = ctx.py_instrument.is_future_continuous_contract("000001.XSHE")
    if Bool(py=result5):
        all_passed = False
        messages.append("000001.XSHE should NOT be continuous contract")
    
    record_result(ctx, "test_future_continuous_contract_detection", all_passed, ", ".join(messages))


def test_contract_multiplier(mut ctx: TestContext) raises:
    var future_inst = get_instrument(ctx, "A0303")
    var mojo_future = py_to_mojo_instrument(future_inst)
    
    var py_multiplier = Float64(py=future_inst.contract_multiplier)
    var mojo_multiplier = mojo_future.contract_multiplier()
    
    var passed = py_multiplier == mojo_multiplier
    var msg = ""
    if not passed:
        msg = "contract_multiplier mismatch: Python=" + String(py_multiplier) + " Mojo=" + String(mojo_multiplier)
    
    record_result(ctx, "test_contract_multiplier", passed, msg)


def generate_report(ctx: TestContext) raises -> String:
    var report = "# Instrument Test Results Comparison\n\n"
    report += "## Test Summary\n\n"
    report += "| Test Name | Status | Message | Python Result | Mojo Result |\n"
    report += "|-----------|--------|---------|---------------|-------------|\n"
    
    var passed_count = 0
    var failed_count = 0
    
    for result in ctx.test_results:
        var status = "PASS"
        if not result.passed:
            status = "FAIL"
            failed_count += 1
        else:
            passed_count += 1
        
        report += "| " + result.test_name + " | " + status + " | " + result.message + " | " + result.python_result + " | " + result.mojo_result + " |\n"
    
    report += "\n## Statistics\n\n"
    report += "- Total Tests: " + String(len(ctx.test_results)) + "\n"
    report += "- Passed: " + String(passed_count) + "\n"
    report += "- Failed: " + String(failed_count) + "\n"
    
    return report


def main() raises:
    print("Running Instrument tests...")
    print("")
    
    var ctx = TestContext()
    
    load_test_data(ctx)
    
    test_basic_properties(ctx)
    test_date_properties(ctx)
    test_account_type(ctx)
    test_trading_hours(ctx)
    test_round_lot_special_cases(ctx)
    test_future_continuous_contract_detection(ctx)
    test_contract_multiplier(ctx)
    
    print("")
    print("=== Test Results ===")
    var passed = 0
    var failed = 0
    for result in ctx.test_results:
        if result.passed:
            passed += 1
            print("[PASS] " + result.test_name)
        else:
            failed += 1
            print("[FAIL] " + result.test_name + ": " + result.message)
    
    print("")
    print("Total: " + String(len(ctx.test_results)) + " tests, " + String(passed) + " passed, " + String(failed) + " failed")
    
    var report = generate_report(ctx)
    var report_path = "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/unittest/test_models/test_instruments_results.md"
    
    var py_open = Python.import_module("builtins").open
    var f = py_open(report_path, "w")
    f.write(report)
    f.close()
    print("")
    print("Report saved to: " + report_path)
