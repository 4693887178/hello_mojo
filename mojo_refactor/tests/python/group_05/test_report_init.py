"""
Test for rqalpha/mod/rqalpha_mod_sys_analyser/report/__init__.py
"""


class TestReportInit:
    """Test report module initialization"""

    def test_generate_report_function_exists(self):
        """Test generate_report function exists"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report import generate_report
        
        assert callable(generate_report)


class TestReportModule:
    """Test report module"""

    def test_report_imports(self):
        """Test report module can be imported"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report import report
        
        assert report is not None

    def test_excel_template_imports(self):
        """Test excel_template module can be imported"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report import excel_template
        
        assert excel_template is not None
