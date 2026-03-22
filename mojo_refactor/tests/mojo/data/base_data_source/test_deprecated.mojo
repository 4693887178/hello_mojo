"""
Mojo Test for data/base_data_source/deprecated.mojo
Tests the InstrumentStore class
"""

from std.collections import Dict, List
from rqmojo.const import INSTRUMENT_TYPE_CS
from rqmojo.model.instrument import Instrument, create_instrument_from_dict
from rqmojo.data.base_data_source.deprecated import InstrumentStore, create_instrument_store


def test_create_instrument_store():
    var instruments = List[Instrument]()
    
    var data1 = Dict[String, String]()
    data1["order_book_id"] = "000001.XSHE"
    data1["symbol"] = "平安银行"
    data1["type"] = "CS"
    data1["listed_date"] = "1991-04-03"
    data1["exchange"] = "XSHE"
    var ins1 = create_instrument_from_dict(data1)
    instruments.append(ins1)
    
    var store = create_instrument_store(instruments, INSTRUMENT_TYPE_CS)
    print("InstrumentStore created")
    assert True


def test_instrument_store_all_id_and_syms():
    var instruments = List[Instrument]()
    
    var data1 = Dict[String, String]()
    data1["order_book_id"] = "000001.XSHE"
    data1["symbol"] = "平安银行"
    data1["type"] = "CS"
    data1["listed_date"] = "1991-04-03"
    data1["exchange"] = "XSHE"
    var ins1 = create_instrument_from_dict(data1)
    instruments.append(ins1)
    
    var store = create_instrument_store(instruments, INSTRUMENT_TYPE_CS)
    var all_ids = store.all_id_and_syms()
    print("All IDs and symbols count: " + String(len(all_ids)))
    assert len(all_ids) == 2


def main():
    print("=== Testing data/base_data_source/deprecated.mojo ===")
    test_create_instrument_store()
    test_instrument_store_all_id_and_syms()
    print("All deprecated tests passed!")
