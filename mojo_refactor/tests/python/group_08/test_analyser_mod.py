# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_analyser/mod.py
Group 08 - File 09
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestAnalyserModStructure:
    def test_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        assert AnalyserMod is not None

    def test_inherits_abstract_mod(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        from rqalpha.interface import AbstractMod
        assert issubclass(AnalyserMod, AbstractMod)

    def test_has_start_up_method(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        assert 'start_up' in dir(AnalyserMod)

    def test_has_tear_down_method(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        assert 'tear_down' in dir(AnalyserMod)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
