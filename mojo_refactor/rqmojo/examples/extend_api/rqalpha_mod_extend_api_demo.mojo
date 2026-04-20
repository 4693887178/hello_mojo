"""
RQAlpha Mojo - Extend API Demo Mod
Ported from rqalpha/examples/extend_api/rqalpha_mod_extend_api_demo.py
"""

from python import os
from python import pandas as pd
from rqmojo.interface import AbstractMod


comptime __config__ = {
    "csv_path": None
}


def load_mod() -> object:
    return ExtendAPIDemoMod()


struct ExtendAPIDemoMod(AbstractMod):
    var _csv_path: String

    def __init__(inout self) -> None:
        self._csv_path = ""

    def start_up(self, env: object, mod_config: object) -> None:
        self._csv_path = os.path.abspath(os.path.join(os.path.dirname(__file__), mod_config.csv_path))

    def tear_down(self, code: object, exception: object = None) -> None:
        pass

    def _inject_api(self) -> None:
        from rqmojo.api import export_as_api
        from rqmojo.core.execution_context import ExecutionContext
        from rqmojo.const import EXECUTION_PHASE

        @export_as_api
        @ExecutionContext.enforce_phase(
            EXECUTION_PHASE_ON_INIT,
            EXECUTION_PHASE_BEFORE_TRADING,
            EXECUTION_PHASE_ON_BAR,
            EXECUTION_PHASE_AFTER_TRADING,
            EXECUTION_PHASE_SCHEDULED
        )
        def get_csv_as_df() -> object:
            var data = pd.read_csv(self._csv_path)
            return data
