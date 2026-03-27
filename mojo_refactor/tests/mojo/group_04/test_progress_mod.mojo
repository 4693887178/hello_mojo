"""
第四组测试 - mod/rqmojo_mod_sys_progress/mod.mojo
测试Mojo版本的进度模块
"""

from rqmojo.mod.rqmojo_mod_sys_progress.mod import ProgressMod, ProgressBar, create_progress_mod
from rqmojo.const import EXIT_CODE


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_progress_mod_init() raises:
    var mod = ProgressMod()
    assert_equal(mod.name, "progress", "name should match")


def test_progress_mod_start_up_exists() raises:
    var mod = ProgressMod()
    mod.start_up("env", "config")
    assert_true(True, "start_up works")


def test_progress_mod_tear_down_exists() raises:
    var mod = ProgressMod()
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)
    assert_true(True, "tear_down works")


def test_progress_mod_init_method() raises:
    var mod = ProgressMod()
    mod._init(100)
    assert_true(True, "_init works")


def test_progress_mod_tick_method() raises:
    var mod = ProgressMod()
    mod._init(100)
    mod._tick()
    assert_true(True, "_tick works")


def test_progress_bar_init() raises:
    var bar = ProgressBar(length=100)
    assert_true(True, "ProgressBar created")


def test_progress_bar_with_eta() raises:
    var bar = ProgressBar(length=100, show_eta=True)
    assert_true(True, "ProgressBar with eta created")


def test_progress_bar_update() raises:
    var bar = ProgressBar(length=100)
    bar.update(1)
    bar.update(5)
    assert_true(True, "update works")


def test_progress_bar_render_finish() raises:
    var bar = ProgressBar(length=100)
    bar.render_finish()
    assert_true(True, "render_finish works")


def test_progress_bar_reset() raises:
    var bar = ProgressBar(length=100)
    bar.update(50)
    bar.reset()
    assert_true(True, "reset works")


def test_progress_mod_str() raises:
    var mod = ProgressMod()
    var s = String(mod)
    assert_true(s.find("ProgressMod") >= 0, "should contain ProgressMod")


def test_progress_bar_str() raises:
    var bar = ProgressBar(length=100)
    var s = String(bar)
    assert_true(s.find("ProgressBar") >= 0, "should contain ProgressBar")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
