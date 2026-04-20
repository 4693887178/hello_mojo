# Test Results: plot.py (Python Original)

**Date**: 2026-04-19
**File**: `rqalpha/mod/rqalpha_mod_sys_analyser/plot/plot.py`
**Test File**: `tests/python/test_plot.py`

## Summary

| Metric | Value |
|--------|-------|
| Total Tests | 21 |
| Passed | 21 |
| Failed | 0 |
| Skipped | 0 |
| Pass Rate | **100%** |

## Test Details

### TestSubPlot (2 tests)
- ✅ `test_can_instantiate` - SubPlot can be created with no-arg init
- ✅ `test_has_height_attribute` - SubPlot has height and right_pad as class annotations

### TestIndicatorArea (3 tests)
- ✅ `test_inherits_from_sub_plot` - IndicatorArea is a SubPlot subclass
- ✅ `test_creation_with_required_args` - IndicatorArea creation with (indicators, indicator_values, plot_template, strategy_name)
- ✅ `test_stores_indicators_and_values` - Verifies internal storage of indicators/values/strategy_name

### TestReturnPlot (3 tests)
- ✅ `test_inherits_from_sub_plot` - ReturnPlot is a SubPlot subclass
- ✅ `test_creation_with_required_args` - ReturnPlot creation with (returns, lines, spots_on_returns)
- ✅ `test_stores_returns_and_lines` - Verifies internal storage of returns/lines/spots

### TestUserPlot (2 tests)
- ✅ `test_inherits_from_sub_plot` - UserPlot is a SubPlot subclass
- ✅ `test_creation_with_dataframe` - UserPlot creation with DataFrame

### TestTitlePlot (2 tests)
- ✅ `test_inherits_from_sub_plot` - TitlePlot is a SubPlot subclass
- ✅ `test_creation_with_required_args` - TitlePlot creation with (strategy_name, indicator_area_rows, plot_template)

### TestWaterMark (2 tests)
- ✅ `test_can_instantiate` - WaterMark creation with (img_width, img_height, strategy_name)
- ✅ `test_has_required_attributes` - Verifies img_width, img_height, logo_img, dpi attributes

### TestPlotResult (2 tests)
- ✅ `test_plot_result_renders_figure` - plot_result renders figure with mocked matplotlib
- ✅ `test_handles_missing_summary_key` - Raises KeyError when summary missing (expected)

### TestDataStructuresConsistency (5 tests)
- ✅ `test_subplot_has_class_annotations` - SubPlot has class-level annotations
- ✅ `test_indicator_area_has_default_height` - Default height from constant
- ✅ `test_return_plot_has_default_height` - Default height from constant
- ✅ `test_user_plot_has_default_height` - Default height from constant
- ✅ `test_title_plot_has_default_height` - Default height from constant

## Warnings

1 warning (from external dependency consts.py, not from test code):
- DeprecationWarning: Use warning instead (from rqalpha consts module)

## Notes

All tests validate the Python original implementation matches expected behavior based on actual class constructor signatures:
- `SubPlot()` - no arguments (class annotations only)
- `IndicatorArea(indicators, indicator_values, plot_template, strategy_name=None)`
- `ReturnPlot(returns, lines, spots_on_returns)`
- `UserPlot(plots_df)`
- `TitlePlot(strategy_name, indicator_area_rows, plot_template)`
- `WaterMark(img_width, img_height, strategy_name)`
- `plot_result(result_dict, show, save, weekly_indicators, open_close_points, plot_template_cls, strategy_name)`
