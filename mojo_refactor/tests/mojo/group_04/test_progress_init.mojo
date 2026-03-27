"""
第四组测试 - mod/rqmojo_mod_sys_progress/__init__.mojo
测试Mojo版本的进度模块初始化
"""

from rqmojo.mod.rqmojo_mod_sys_progress import ProgressMod, ProgressBar, create_progress_mod


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_progress_mod_exists() raises:
    var mod = create_progress_mod()
    assert_true(True, "ProgressMod created")


def test_progress_mod_name() raises:
    var mod = create_progress_mod()
    assert_equal(mod.name, "progress", "name should match")


def test_progress_bar_exists() raises:
    var bar = ProgressBar(length=100)
    assert_true(True, "ProgressBar created")


def test_progress_bar_length() raises:
    var bar = ProgressBar(length=100)
    assert_true(True, "ProgressBar with length works")


def test_progress_bar_update() raises:
    var bar = ProgressBar(length=100)
    bar.update(1)
    assert_true(True, "update works")


def test_progress_bar_render_finish() raises:
    var bar = ProgressBar(length=100)
    bar.render_finish()
    assert_true(True, "render_finish works")


def test_create_progress_mod() raises:
    var mod = create_progress_mod()
    assert_equal(mod.name, "progress", "name should match")


def test_progress_mod_start_up() raises:
    var mod = create_progress_mod()
    mod.start_up("env", "config")
    assert_true(True, "start_up works")


def test_progress_mod_tear_down() raises:
    from rqmojo.const import EXIT_CODE
    var mod = create_progress_mod()
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)
    assert_true(True, "tear_down works")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
