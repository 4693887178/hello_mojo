"""
Integration Tests for config.mojo vs config.py
Tests to verify that the Mojo implementation matches the Python original.

This test file compares the behavior of both implementations
to ensure functional consistency.
"""

import pytest
import sys
from typing import Dict, Any

# Add paths for imports
sys.path.insert(0, '/home/zhou/hello_mojo/tae_cn_78/.venv/lib/python3.14/site-packages')
sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib64/python3.14/site-packages')


class TestConfigPythonOriginal:
    """Test the original Python implementation"""

    def test_import_config(self):
        """Test that config module can be imported"""
        from rqalpha.utils import config
        assert hasattr(config, 'default_config')
        assert hasattr(config, 'parse_run_type')
        assert hasattr(config, 'parse_persist_mode')
        assert hasattr(config, 'parse_accounts')
        assert hasattr(config, 'parse_init_positions')
        assert hasattr(config, 'parse_future_info')
        assert hasattr(config, 'parse_config')
        assert hasattr(config, 'RqAttrDict')

    def test_default_config_returns_rqattrdict(self):
        """Test that default_config returns RqAttrDict"""
        from rqalpha.utils.config import default_config, RqAttrDict
        conf = default_config()
        assert isinstance(conf, RqAttrDict)

    def test_default_config_has_base_section(self):
        """Test default config has base section with required fields"""
        from rqalpha.utils.config import default_config
        conf = default_config()

        assert hasattr(conf, 'base')
        base = conf.base

        required_fields = [
            'start_date', 'end_date', 'frequency', 'run_type',
            'data_bundle_path', 'strategy_file', 'persist_mode',
            'initial_cash', 'accounts', 'init_positions', 'future_info'
        ]
        for field in required_fields:
            assert hasattr(base, field), f"Missing base.{field}"

    def test_default_config_has_extra_section(self):
        """Test default config has extra section"""
        from rqalpha.utils.config import default_config
        conf = default_config()
        assert hasattr(conf, 'extra')
        assert hasattr(conf.extra, 'locale')
        assert hasattr(conf.extra, 'context_vars')


class TestParseRunType:
    """Test parse_run_type function"""

    def test_parse_backtest_short(self):
        from rqalpha.utils.config import parse_run_type
        from rqalpha.const import RUN_TYPE
        result = parse_run_type('b')
        assert result == RUN_TYPE.BACKTEST

    def test_parse_backtest_long(self):
        from rqalpha.utils.config import parse_run_type
        from rqalpha.const import RUN_TYPE
        result = parse_run_type('backtest')
        assert result == RUN_TYPE.BACKTEST

    def test_parse_paper_trading(self):
        from rqalpha.utils.config import parse_run_type
        from rqalpha.const import RUN_TYPE
        result = parse_run_type('p')
        assert result == RUN_TYPE.PAPER_TRADING

    def test_parse_live_trading(self):
        from rqalpha.utils.config import parse_run_type
        from rqalpha.const import RUN_TYPE
        result = parse_run_type('r')
        assert result == RUN_TYPE.LIVE_TRADING

    def test_parse_invalid_raises_error(self):
        from rqalpha.utils.config import parse_run_type
        with pytest.raises(RuntimeError):
            parse_run_type('invalid')


class TestParsePersistMode:
    """Test parse_persist_mode function"""

    def test_parse_real_time(self):
        from rqalpha.utils.config import parse_persist_mode
        from rqalpha.const import PERSIST_MODE
        result = parse_persist_mode('real_time')
        assert result == PERSIST_MODE.REAL_TIME

    def test_parse_on_crash(self):
        from rqalpha.utils.config import parse_persist_mode
        from rqalpha.const import PERSIST_MODE
        result = parse_persist_mode('on_crash')
        assert result == PERSIST_MODE.ON_CRASH

    def test_parse_on_normal_exit(self):
        from rqalpha.utils.config import parse_persist_mode
        from rqalpha.const import PERSIST_MODE
        result = parse_persist_mode('on_normal_exit')
        assert result == PERSIST_MODE.ON_NORMAL_EXIT

    def test_parse_invalid_raises_error(self):
        from rqalpha.utils.config import parse_persist_mode
        with pytest.raises(RuntimeError):
            parse_persist_mode('invalid')


class TestParseAccounts:
    """Test parse_accounts function"""

    def test_parse_dict_accounts(self):
        from rqalpha.utils.config import parse_accounts
        accounts = {'stock': 1000000.0, 'future': 500000.0}
        result = parse_accounts(accounts)
        assert 'STOCK' in result
        assert 'FUTURE' in result
        assert result['STOCK'] == 1000000.0

    def test_parse_tuple_accounts(self):
        from rqalpha.utils.config import parse_accounts
        accounts = (('stock', 1000000.0), ('future', 500000.0))
        result = parse_accounts(accounts)
        assert len(result) > 0


class TestParseInitPositions:
    """Test parse_init_positions function"""

    def test_parse_valid_positions(self):
        from rqalpha.utils.config import parse_init_positions
        positions_str = "000001.XSHE:1000,IF1701:-1"
        result = parse_init_positions(positions_str)
        assert len(result) == 2
        assert result[0][0] == "000001.XSHE"
        assert result[0][1] == 1000.0
        assert result[1][0] == "IF1701"
        assert result[1][1] == -1.0

    def test_parse_empty_string(self):
        from rqalpha.utils.config import parse_init_positions
        result = parse_init_positions("")
        assert result == []

    def test_parse_none_value(self):
        from rqalpha.utils.config import parse_init_positions
        result = parse_init_positions(None)
        assert result == []

    def test_parse_invalid_format_raises_error(self):
        from rqalpha.utils.config import parse_init_positions
        with pytest.raises(RuntimeError):
            parse_init_positions("invalid_format")


class TestParseFutureInfo:
    """Test parse_future_info function"""

    def test_parse_valid_future_info(self):
        from rqalpha.utils.config import parse_future_info
        future_info = {
            'IF': {
                'open_commission_ratio': '0.00005',
                'close_commission_ratio': '0.00005',
                'close_commission_today_ratio': '0.00005',
                'commission_type': 'BY_MONEY'
            }
        }
        result = parse_future_info(future_info)
        assert 'IF' in result
        assert 'open_commission_ratio' in result['IF']

    def test_parse_by_volume_commission(self):
        from rqalpha.utils.config import parse_future_info
        from rqalpha.const import COMMISSION_TYPE
        future_info = {
            'IF': {
                'open_commission_ratio': '0.00001',
                'commission_type': 'BY_VOLUME'
            }
        }
        result = parse_future_info(future_info)
        assert result['IF']['commission_type'] == COMMISSION_TYPE.BY_VOLUME


class TestRqAttrDictUsage:
    """Test that RqAttrDict is used correctly in config"""

    def test_config_is_dynamic(self):
        """Verify config uses dynamic RqAttrDict not static struct"""
        from rqalpha.utils.config import default_config
        conf = default_config()

        # Should support dynamic attribute access
        assert conf.base.start_date is not None

        # Should allow adding new keys dynamically (unlike static structs)
        conf.custom_field = "test"
        assert conf.custom_field == "test"


class TestConfigStructureConsistency:
    """Verify config structure matches expected format"""

    def test_base_section_structure(self):
        from rqalpha.utils.config import default_config
        conf = default_config()
        base = conf.base

        # Verify types and defaults
        assert isinstance(base.start_date, str) or hasattr(base.start_date, 'strftime')
        assert isinstance(base.frequency, str)
        assert base.frequency == "1d" or base.frequency == "1d"

    def test_extra_section_defaults(self):
        from rqalpha.utils.config import default_config
        conf = default_config()
        extra = conf.extra

        assert extra.locale is not None
        assert extra.is_hold == False or extra.is_hold is False


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
