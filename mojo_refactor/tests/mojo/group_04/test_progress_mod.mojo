"""
Test suite for rqmojo/mod/rqmojo_mod_sys_progress/mod.mojo
Covers all edge cases for ProgressMod and ProgressBar.
"""

from rqmojo.mod.rqmojo_mod_sys_progress.mod import (
    ProgressMod, ProgressBar, create_progress_mod,
)
from rqmojo.const import EXIT_CODE

from std.testing import (
    assert_equal, assert_true, assert_false,
    assert_raises, TestSuite,
)


def test_progress_mod_default_init() raises:
    var mod = ProgressMod()
    assert_equal(mod.name, "progress")
    assert_false(mod._show)
    assert_true(mod._progress_bar == None)
    assert_equal(mod._trading_length, 0)
    assert_false(mod._initialized)


def test_progress_mod_start_up_noop() raises:
    var mod = ProgressMod()
    mod.start_up("env", "config")
    assert_false(mod._show)


def test_progress_mod_start_up_with_config_show() raises:
    var mod = ProgressMod()
    mod.start_up_with_config(True)
    assert_true(mod._show)


def test_progress_mod_start_up_with_config_hide() raises:
    var mod = ProgressMod()
    mod._show = True
    mod.start_up_with_config(False)
    assert_false(mod._show)


def test_progress_mod_init_sets_trading_length() raises:
    var mod = ProgressMod()
    mod._init(252)
    assert_equal(mod._trading_length, 252)
    assert_true(mod._progress_bar != None)
    assert_true(mod._initialized)


def test_progress_mod_init_zero_length() raises:
    var mod = ProgressMod()
    mod._init(0)
    assert_equal(mod._trading_length, 0)
    assert_true(mod._progress_bar != None)
    assert_true(mod._initialized)


def test_progress_mod_tick_increments_bar() raises:
    var mod = ProgressMod()
    mod._init(100)
    mod._tick()
    var bar = mod._progress_bar.value().copy()
    assert_equal(bar._current, 1)


def test_progress_mod_tick_multiple_times() raises:
    var mod = ProgressMod()
    mod._init(10)
    for _ in range(5):
        mod._tick()
    var bar = mod._progress_bar.value().copy()
    assert_equal(bar._current, 5)


def test_progress_mod_tick_without_init() raises:
    var mod = ProgressMod()
    mod._tick()


def test_progress_mod_tear_down_show_and_initialized() raises:
    var mod = ProgressMod()
    mod.start_up_with_config(True)
    mod._init(100)
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)


def test_progress_mod_tear_down_not_show() raises:
    var mod = ProgressMod()
    mod.start_up_with_config(False)
    mod._init(100)
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)


def test_progress_mod_tear_down_not_initialized() raises:
    var mod = ProgressMod()
    mod.start_up_with_config(True)
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)


def test_progress_mod_tear_down_no_bar() raises:
    var mod = ProgressMod()
    mod.start_up_with_config(True)
    mod._initialized = True
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)


def test_progress_mod_tear_down_with_exception() raises:
    var mod = ProgressMod()
    mod.start_up_with_config(True)
    mod._init(50)
    mod.tear_down(EXIT_CODE.EXIT_USER_ERROR, Optional[String](None))


def test_progress_bar_default_init() raises:
    var bar = ProgressBar(length=100)
    assert_equal(bar._length, 100)
    assert_equal(bar._current, 0)
    assert_false(bar._show_eta)


def test_progress_bar_with_eta() raises:
    var bar = ProgressBar(length=200, show_eta=True)
    assert_equal(bar._length, 200)
    assert_equal(bar._current, 0)
    assert_true(bar._show_eta)


def test_progress_bar_update_single_step() raises:
    var bar = ProgressBar(length=100)
    bar.update()
    assert_equal(bar._current, 1)


def test_progress_bar_update_custom_steps() raises:
    var bar = ProgressBar(length=100)
    bar.update(5)
    assert_equal(bar._current, 5)


def test_progress_bar_update_clamps_to_max() raises:
    var bar = ProgressBar(length=10)
    bar.update(20)
    assert_equal(bar._current, 10)


def test_progress_bar_update_accumulates() raises:
    var bar = ProgressBar(length=100)
    bar.update(30)
    bar.update(40)
    assert_equal(bar._current, 70)


def test_progress_bar_update_exact_max() raises:
    var bar = ProgressBar(length=50)
    bar.update(50)
    assert_equal(bar._current, 50)


def test_progress_bar_render_finish() raises:
    var bar = ProgressBar(length=100)
    bar.render_finish()


def test_progress_bar_reset() raises:
    var bar = ProgressBar(length=100)
    bar.update(80)
    bar.reset()
    assert_equal(bar._current, 0)


def test_progress_bar_zero_length_no_crash() raises:
    var bar = ProgressBar(length=0)
    bar.update(1)
    bar.render_finish()


def test_progress_bar_writable() raises:
    var bar = ProgressBar(length=42)
    var s = String(bar)
    assert_true(s.find("ProgressBar") >= 0)
    assert_true(s.find("42") >= 0)
    assert_true(s.find("current") >= 0)


def test_progress_mod_writable() raises:
    var mod = ProgressMod()
    var s = String(mod)
    assert_true(s.find("ProgressMod") >= 0)
    assert_true(s.find("progress") >= 0)


def test_progress_mod_writable_with_show() raises:
    var mod = ProgressMod()
    mod.start_up_with_config(True)
    var s = String(mod)
    assert_true(s.find("show=") >= 0)


def test_create_progress_mod_returns_valid() raises:
    var mod = create_progress_mod()
    assert_equal(mod.name, "progress")
    assert_false(mod._show)


def test_full_lifecycle_visible() raises:
    var mod = create_progress_mod()
    mod.start_up_with_config(True)
    mod._init(250)

    for _ in range(250):
        mod._tick()

    var bar = mod._progress_bar.value().copy()
    assert_equal(bar._current, 250)

    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)


def test_full_lifecycle_hidden() raises:
    var mod = create_progress_mod()
    mod.start_up_with_config(False)
    mod._init(250)

    for _ in range(250):
        mod._tick()

    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
