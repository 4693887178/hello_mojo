# test_L03_01_instrument.py
# Module: rqalpha.model.instrument
# Level: L03 - Data Model
# Dependencies: const, datetime, environment

import pytest
from datetime import datetime


class TestInstrumentBasic:
    """Test Instrument basic functionality"""
    
    def test_instrument_exists(self):
        """Test Instrument class exists"""
        from rqalpha.model.instrument import Instrument
        assert Instrument is not None
    
    def test_instrument_init_stock(self):
        """Test Instrument initialization for stock"""
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import INSTRUMENT_TYPE
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "round_lot": 100,
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "type": "CS",
            "exchange": "XSHE",
        })
        assert ins.order_book_id == "000001.XSHE"
        assert ins.symbol == "平安银行"
        assert ins.type == INSTRUMENT_TYPE.CS
    
    def test_instrument_init_future(self):
        """Test Instrument initialization for future"""
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import INSTRUMENT_TYPE
        
        ins = Instrument({
            "order_book_id": "IF2401.CFFEX",
            "symbol": "沪深2401",
            "round_lot": 1,
            "listed_date": "2023-01-01",
            "de_listed_date": "2024-01-19",
            "type": "Future",
            "exchange": "CFFEX",
            "contract_multiplier": 300.0,
            "maturity_date": "2024-01-19",
        })
        assert ins.order_book_id == "IF2401.CFFEX"
        assert ins.type == INSTRUMENT_TYPE.FUTURE
        assert ins.contract_multiplier == 300.0


class TestInstrumentProperties:
    """Test Instrument properties"""
    
    def test_order_book_id(self):
        """Test order_book_id property"""
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "600000.XSHG",
            "symbol": "浦发银行",
            "type": "CS",
            "exchange": "XSHG",
            "listed_date": "1999-11-10",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        assert ins.order_book_id == "600000.XSHG"
    
    def test_symbol(self):
        """Test symbol property"""
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000002.XSHE",
            "symbol": "万科A",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-01-29",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        assert ins.symbol == "万科A"
    
    def test_round_lot(self):
        """Test round_lot property"""
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
            "board_type": "MainBoard",
        })
        assert ins.round_lot == 100
    
    def test_exchange(self):
        """Test exchange property"""
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import EXCHANGE
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        assert ins.exchange == "XSHE"


class TestInstrumentMethods:
    """Test Instrument methods"""
    
    def test_tick_size_stock(self):
        """Test tick_size for stock"""
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        assert ins.tick_size() == 0.01
    
    def test_tick_size_etf(self):
        """Test tick_size for ETF"""
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "510050.XSHG",
            "symbol": "50ETF",
            "type": "ETF",
            "exchange": "XSHG",
            "listed_date": "2004-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        assert ins.tick_size() == 0.001
    
    def test_account_type_stock(self):
        """Test account_type for stock"""
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import DEFAULT_ACCOUNT_TYPE
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        assert ins.account_type == DEFAULT_ACCOUNT_TYPE.STOCK
    
    def test_account_type_future(self):
        """Test account_type for future"""
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import DEFAULT_ACCOUNT_TYPE
        
        ins = Instrument({
            "order_book_id": "IF2401.CFFEX",
            "symbol": "沪深2401",
            "type": "Future",
            "exchange": "CFFEX",
            "listed_date": "2023-01-01",
            "de_listed_date": "2024-01-19",
            "round_lot": 1,
            "contract_multiplier": 300.0,
        })
        assert ins.account_type == DEFAULT_ACCOUNT_TYPE.FUTURE


class TestInstrumentDateMethods:
    """Test Instrument date methods"""
    
    def test_listed_at(self):
        """Test listed_at method"""
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        assert ins.listed_at(datetime(2020, 1, 1)) == True
        assert ins.listed_at(datetime(1990, 1, 1)) == False
    
    def test_de_listed_at(self):
        """Test de_listed_at method"""
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2020-01-01",
            "round_lot": 100,
        })
        assert ins.de_listed_at(datetime(2020, 1, 1)) == True
        assert ins.de_listed_at(datetime(2019, 12, 31)) == False
    
    def test_active_at(self):
        """Test active_at method"""
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        assert ins.active_at(datetime(2020, 1, 1)) == True


class TestInstrumentContinuousContract:
    """Test Instrument continuous contract detection"""
    
    def test_is_future_continuous_contract_88(self):
        """Test is_future_continuous_contract with 88 suffix"""
        from rqalpha.model.instrument import Instrument
        
        assert Instrument.is_future_continuous_contract("IF88") is not None
        assert Instrument.is_future_continuous_contract("IC88") is not None
    
    def test_is_future_continuous_contract_99(self):
        """Test is_future_continuous_contract with 99 suffix"""
        from rqalpha.model.instrument import Instrument
        
        assert Instrument.is_future_continuous_contract("IF99") is not None
    
    def test_is_future_continuous_contract_normal(self):
        """Test is_future_continuous_contract with normal contract"""
        from rqalpha.model.instrument import Instrument
        
        assert Instrument.is_future_continuous_contract("IF2401") is None


class TestSectorCode:
    """Test SectorCode class"""
    
    def test_sector_code_exists(self):
        """Test SectorCode class exists"""
        from rqalpha.model.instrument import SectorCode
        assert SectorCode is not None
    
    def test_sector_code_energy(self):
        """Test SectorCode Energy"""
        from rqalpha.model.instrument import SectorCode
        
        assert SectorCode.Energy.cn == "能源"
        assert SectorCode.Energy.en == "energy"


class TestIndustryCode:
    """Test IndustryCode class"""
    
    def test_industry_code_exists(self):
        """Test IndustryCode class exists"""
        from rqalpha.model.instrument import IndustryCode
        assert IndustryCode is not None
    
    def test_industry_code_a01(self):
        """Test IndustryCode A01"""
        from rqalpha.model.instrument import IndustryCode
        
        assert IndustryCode.A01.code == "A01"
        assert IndustryCode.A01.name == "农业"
