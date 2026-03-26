"""
Test for rqalpha/mod/rqalpha_mod_sys_analyser/report/excel_template.py
"""


class TestExcelTemplate:
    """Test ExcelTemplate class"""

    def test_excel_template_class_exists(self):
        """Test ExcelTemplate class exists"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.excel_template import ExcelTemplate
        
        assert ExcelTemplate is not None

    def test_sheet_schema_class_exists(self):
        """Test SheetSchema class exists"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.excel_template import SheetSchema
        
        assert SheetSchema is not None

    def test_single_cell_schema_class_exists(self):
        """Test SingleCellSchema class exists"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.excel_template import SingleCellSchema
        
        assert SingleCellSchema is not None

    def test_vertical_series_schema_class_exists(self):
        """Test VerticalSeriesSchema class exists"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.excel_template import VerticalSeriesSchema
        
        assert VerticalSeriesSchema is not None

    def test_summary_template_class_exists(self):
        """Test SummaryTemplate class exists"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.excel_template import SummaryTemplate
        
        assert SummaryTemplate is not None


class TestValueNameRegex:
    """Test VALUE_NAME_RE regex"""

    def test_value_name_re_exists(self):
        """Test VALUE_NAME_RE constant exists"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.excel_template import VALUE_NAME_RE
        
        assert VALUE_NAME_RE is not None
        assert isinstance(VALUE_NAME_RE, str)


class TestGenerateXlsxReports:
    """Test generate_xlsx_reports function"""

    def test_generate_xlsx_reports_function_exists(self):
        """Test generate_xlsx_reports function exists"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.excel_template import generate_xlsx_reports
        
        assert callable(generate_xlsx_reports)


class TestSummaryTemplateConstants:
    """Test SummaryTemplate constants"""

    def test_template_name(self):
        """Test TEMPLATE_NAME constant"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.excel_template import SummaryTemplate
        
        assert SummaryTemplate.TEMPLATE_NAME == "summary"

    def test_schema_classes(self):
        """Test SCHEMA_CLASSES dictionary"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.excel_template import SummaryTemplate
        
        assert isinstance(SummaryTemplate.SCHEMA_CLASSES, dict)
        assert "概览" in SummaryTemplate.SCHEMA_CLASSES
        assert "年度指标" in SummaryTemplate.SCHEMA_CLASSES
        assert "月度收益" in SummaryTemplate.SCHEMA_CLASSES
