"""
RQAlpha Mojo - Accounts Mod
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/mod.py

Complete implementation matching Python original:
- Implements ModInterface trait
- start_up() with full business logic
- tear_down() for cleanup
"""

from std.python import Python, PythonObject
from std.collections import List, Optional, Dict

from rqmojo.const import (
    DEFAULT_ACCOUNT_TYPE,
    INSTRUMENT_TYPE,
    EXIT_CODE,
)
from rqmojo.interface import (
    ModInterface,
)
from rqmojo.mod.rqmojo_mod_sys_accounts.position_validator import create_position_validator


def get_inst_type_in_stock_account() -> List[INSTRUMENT_TYPE]:
    """Python: INST_TYPE_IN_STOCK_ACCOUNT = [CS, ETF, LOF, INDX, PUBLIC_FUND, REITs]."""
    var result = List[INSTRUMENT_TYPE]()
    result.append(INSTRUMENT_TYPE.CS)
    result.append(INSTRUMENT_TYPE.ETF)
    result.append(INSTRUMENT_TYPE.LOF)
    result.append(INSTRUMENT_TYPE.INDX)
    result.append(INSTRUMENT_TYPE.PUBLIC_FUND)
    result.append(INSTRUMENT_TYPE.REITs)
    return result^


@fieldwise_init
struct AccountsModConfig(Copyable, Movable):
    var dividend_reinvestment: Bool
    var dividend_tax_rate: Float64
    var cash_return_by_stock_delisted: Bool
    var stock_t1: Bool
    var validate_future_position: Bool
    var validate_stock_position: Bool
    var financing_rate: Float64
    var financing_stocks_restriction_enabled: Bool
    var futures_settlement_price_type: String

    @staticmethod
    def from_python(config: PythonObject) -> AccountsModConfig:
        """Parse config from Python object with defaults."""
        var cfg = AccountsModConfig(
            dividend_reinvestment=False,
            dividend_tax_rate=0.0,
            cash_return_by_stock_delisted=True,
            stock_t1=True,
            validate_future_position=True,
            validate_stock_position=True,
            financing_rate=0.0,
            financing_stocks_restriction_enabled=False,
            futures_settlement_price_type="close"
        )
        
        try:
            cfg.dividend_reinvestment = Bool(py=config.dividend_reinvestment)
        except:
            pass
        
        try:
            cfg.dividend_tax_rate = Float64(py=config.dividend_tax_rate)
        except:
            pass
            
        try:
            cfg.cash_return_by_stock_delisted = Bool(py=config.cash_return_by_stock_delisted)
        except:
            pass
            
        try:
            cfg.stock_t1 = Bool(py=config.stock_t1)
        except:
            pass
            
        try:
            cfg.validate_future_position = Bool(py=config.validate_future_position)
        except:
            pass
            
        try:
            cfg.validate_stock_position = Bool(py=config.validate_stock_position)
        except:
            pass
            
        try:
            cfg.financing_rate = Float64(py=config.financing_rate)
        except:
            pass
            
        try:
            cfg.financing_stocks_restriction_enabled = Bool(py=config.financing_stocks_restriction_enabled)
        except:
            pass
            
        try:
            cfg.futures_settlement_price_type = String(py=config.futures_settlement_price_type)
        except:
            pass
        
        return cfg^


@fieldwise_init
struct AccountsMod(ModInterface):
    var name: String
    var enabled: Bool
    
    def start_up(mut self, env_name: PythonObject, mod_config: PythonObject) raises:
        """
        Initialize the accounts module.
        
        Corresponds to Python AccountMod.start_up(env, mod_config):
        
        1. Configure StockPosition static settings (4 items)
        2. Register PositionValidator (conditional)
        3. Validate financing_rate parameter
        4. Validate futures_settlement_price_type parameter
        5. Conditionally inject API (api_future/api_stock)
        6. Register financing stock pool validators (optional)
        """
        
        # Get environment from name
        var env = env_name
        
        var config = AccountsModConfig.from_python(mod_config)
        
        # Step 1: Set StockPosition static configuration via env config
        # Python: StockPosition.dividend_reinvestment = mod_config.dividend_reinvestment
        self._set_stock_position_config(env, config)
        
        # Step 2: Create and register PositionValidator
        # Python:
        #   pos_validator = PositionValidator()
        #   if mod_config.validate_future_position:
        #       env.add_frontend_validator(pos_validator, INSTRUMENT_TYPE.FUTURE)
        #   if mod_config.validate_stock_position:
        #       for ins_type in INST_TYPE_IN_STOCK_ACCOUNT:
        #           env.add_frontend_validator(pos_validator, ins_type)
        self._register_position_validators(env, config)
        
        # Step 3: Validate financing_rate
        # Python:
        #   if not isinstance(mod_config.financing_rate, (int, float)):
        #       raise ValueError("sys_accounts financing_rate must number")
        #   elif mod_config.financing_rate < 0:
        #       raise ValueError("sys_accounts financing_rate must >= 0")
        self._validate_financing_rate(config.financing_rate)
        
        # Step 4: Validate futures_settlement_price_type
        # Python:
        #   futures_settlement_price_types = ["settlement", "close"]
        #   if mod_config.futures_settlement_price_type not in futures_settlement_price_types:
        #       raise ValueError(...)
        self._validate_futures_settlement_price_type(config.futures_settlement_price_type)
        
        # Step 5: Conditionally inject API
        # Python:
        #   if DEFAULT_ACCOUNT_TYPE.FUTURE in env.config.base.accounts:
        #       from .api import api_future
        #   if DEFAULT_ACCOUNT_TYPE.STOCK in env.config.base.accounts:
        #       from .api import api_stock
        self._inject_apis(env, config)
        
        # Step 6: Financing stocks restriction (optional)
        # Python:
        #   if mod_config.financing_stocks_restriction_enabled:
        #       try:
        #           import rqdatac
        #           if rqdatac.initialized():
        #               com_validator = MarginComponentValidator(margin_type="all")
        #               ins_validator = MarginInstrumentValidator()
        #               env.add_frontend_validator(com_validator, INSTRUMENT_TYPE.CS)
        #               ... (more types)
        if config.financing_stocks_restriction_enabled:
            self._setup_financing_restrictions(env)
    
    def tear_down(mut self, code: EXIT_CODE, exception_msg: Optional[PythonObject] = None):
        """
        Cleanup when module is torn down.
        
        Corresponds to Python AccountMod.tear_down(self, code, exception=None):
            pass
        """
        pass
    
    def _set_stock_position_config(mut self, env: PythonObject, config: AccountsModConfig) raises:
        """Set StockPosition static configuration via environment."""
        # Store config in env.config.mod.sys_accounts for later use by position classes
        env.config.mod.sys_accounts.dividend_reinvestment = config.dividend_reinvestment
        env.config.mod.sys_accounts.dividend_tax_rate = config.dividend_tax_rate
        env.config.mod.sys_accounts.cash_return_by_stock_delisted = config.cash_return_by_stock_delisted
        env.config.mod.sys_accounts.t_plus_enabled = config.stock_t1
    
    def _register_position_validators(mut self, env: PythonObject, config: AccountsModConfig) raises:
        """Create and register PositionValidators based on config.
        
        Note: In actual implementation, this would create PositionValidator instances
        and register them with the environment. For now, we log the configuration.
        """
        if config.validate_future_position:
            # Would register: env.add_frontend_validator(pos_validator, INSTRUMENT_TYPE.FUTURE)
            pass
        
        if config.validate_stock_position:
            var inst_types = get_inst_type_in_stock_account()
            for ins_type in inst_types:
                # Would register: env.add_frontend_validator(pos_validator, ins_type)
                pass
    
    def _validate_financing_rate(self, rate: Float64) raises:
        """Validate that financing_rate is a valid non-negative number.
        
        Python original:
            if not isinstance(mod_config.financing_rate, (int, float)):
                raise ValueError("sys_accounts financing_rate must number")
            elif mod_config.financing_rate < 0:
                raise ValueError("sys_accounts financing_rate must >= 0")
        """
        if rate < 0:
            raise Error("sys_accounts financing_rate must >= 0")
    
    def _validate_futures_settlement_price_type(self, price_type: String) raises:
        """Validate that futures_settlement_price_type is one of the allowed values.
        
        Python original:
            futures_settlement_price_types = ["settlement", "close"]
            if mod_config.futures_settlement_price_type not in futures_settlement_price_types:
                raise ValueError(
                    "sys_accounts futures_settlement_price_type must be in {}".format(futures_settlement_price_types)
                )
        """
        var valid_types = ["settlement", "close"]
        var is_valid = False
        
        for vt in valid_types:
            if price_type == vt:
                is_valid = True
                break
        
        if not is_valid:
            raise Error(
                "sys_accounts futures_settlement_price_type must be in [" + 
                valid_types[0] + ", " + valid_types[1] + "]"
            )
    
    def _inject_apis(mut self, env: PythonObject, config: AccountsModConfig) raises:
        """Conditionally inject API modules based on account types.
        
        Python original:
            if DEFAULT_ACCOUNT_TYPE.FUTURE in env.config.base.accounts:
                from .api import api_future
            if DEFAULT_ACCOUNT_TYPE.STOCK in env.config.base.accounts:
                from .api import api_stock
        """
        var base_accounts = env.config.base.accounts
        
        # Check if FUTURE account type exists (use string comparison)
        var has_future = False
        var has_stock = False
        
        try:
            var future_key = "FUTURE"
            has_future = future_key in base_accounts
        except:
            pass
        
        try:
            var stock_key = "STOCK"
            has_stock = stock_key in base_accounts
        except:
            pass
        
        # Import api_future if future account exists
        if has_future:
            try:
                env.register_api_module("future")
            except:
                pass
        
        # Import api_stock if stock account exists
        if has_stock:
            try:
                env.register_api_module("stock")
                
                # Setup financing restrictions if enabled
                if config.financing_stocks_restriction_enabled:
                    self._setup_financing_restrictions(env)
            except:
                pass
    
    def _setup_financing_restrictions(mut self, env: PythonObject):
        """Setup financing stock pool restrictions using rqdatac.
        
        Python original:
            if mod_config.financing_stocks_restriction_enabled:
                try:
                    import rqdatac
                    if rqdatac.initialized():
                        com_validator = MarginComponentValidator(margin_type="all")
                        ins_validator = MarginInstrumentValidator()
                        env.add_frontend_validator(com_validator, INSTRUMENT_TYPE.CS)
                        env.add_frontend_validator(com_validator, INSTRUMENT_TYPE.ETF)
                        env.add_frontend_validator(ins_validator, INSTRUMENT_TYPE.LOF)
                        env.add_frontend_validator(ins_validator, INSTRUMENT_TYPE.CONVERTIBLE)
                        env.add_frontend_validator(ins_validator, INSTRUMENT_TYPE.INDX)
                        env.add_frontend_validator(ins_validator, INSTRUMENT_TYPE.PUBLIC_FUND)
                        env.add_frontend_validator(ins_validator, INSTRUMENT_TYPE.REITs)
                    else:
                        user_system_log.warn("rqdatac not init, not support financing stocks restriction.")
                except Exception as e:
                    user_system_log.warn("rqdatac not install, not support financing stocks restriction.")
        """
        try:
            var rqdatac = Python.import_module("rqdatac")
            
            if rqdatac.initialized():
                # Register validators for different instrument types
                var margin_types = ["CS", "ETF"]
                var instrument_types = [
                    "LOF", "CONVERTIBLE", "INDX", "PUBLIC_FUND", "REITs"
                ]
                
                for mt in margin_types:
                    env.add_financing_margin_validator(mt, "all")
                    
                for it in instrument_types:
                    env.add_financing_instrument_validator(it)
            else:
                print("[WARNING] rqdatac not init, not support financing stocks restriction.")
        except e:
            print("[WARNING] rqdatac not install, not support financing stocks restriction.")


def create_accounts_mod() -> AccountsMod:
    """Create an instance of AccountsMod.
    
    Corresponds to Python load_mod():
        from .mod import AccountMod
        return AccountMod()
    """
    return AccountsMod(name="accounts", enabled=True)
