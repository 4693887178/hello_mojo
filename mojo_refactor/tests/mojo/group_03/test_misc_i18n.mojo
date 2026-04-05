"""
Test for misc.mojo i18n integration
Verifies that CLI command help text goes through gettext translation.
Uses std.testing framework (TestSuite, assert_equal).
"""

from rqmojo.cmds.misc import (
    create_examples_command,
    create_version_command,
    create_generate_config_command,
)
from rqmojo.utils.i18n import gettext, set_locale, get_locale

from std.testing import assert_equal, assert_true, assert_not_equal, TestSuite


def test_examples_command_help_english() raises:
    set_locale("en_US")
    var cmd = create_examples_command()
    var expected_en = "Generate example strategies to target folder"
    assert_equal(cmd.description, expected_en)


def test_examples_command_help_chinese() raises:
    set_locale("zh_CN")
    var cmd = create_examples_command()
    var expected_zh = "在目标文件夹生成样例策略"
    assert_equal(cmd.description, expected_zh)


def test_version_command_help_english() raises:
    set_locale("en_US")
    var cmd = create_version_command()
    var expected_en = "Output Version Info"
    assert_equal(cmd.description, expected_en)


def test_version_command_help_chinese() raises:
    set_locale("zh_CN")
    var cmd = create_version_command()
    var expected_zh = "输出版本号信息"
    assert_equal(cmd.description, expected_zh)


def test_generate_config_command_help_english() raises:
    set_locale("en_US")
    var cmd = create_generate_config_command()
    var expected_en = "Generate default config file"
    assert_equal(cmd.description, expected_en)


def test_generate_config_command_help_chinese() raises:
    set_locale("zh_CN")
    var cmd = create_generate_config_command()
    var expected_zh = "生成默认的配置文件"
    assert_equal(cmd.description, expected_zh)


def test_gettext_direct_translation_misc_strings() raises:
    set_locale("zh_CN")
    assert_equal(
        gettext("Generate example strategies to target folder"),
        "在目标文件夹生成样例策略",
    )
    assert_equal(gettext("Output Version Info"), "输出版本号信息")
    assert_equal(gettext("Generate default config file"), "生成默认的配置文件")


def test_gettext_passthrough_for_unknown() raises:
    set_locale("zh_CN")
    var unknown = "this string has no translation"
    assert_equal(gettext(unknown), unknown)


def test_locale_switch_translates_same_string() raises:
    set_locale("en_US")
    var en_result = gettext("Generate example strategies to target folder")

    set_locale("zh_CN")
    var zh_result = gettext("Generate example strategies to target folder")

    assert_equal(en_result, "Generate example strategies to target folder")
    assert_equal(zh_result, "在目标文件夹生成样例策略")
    assert_not_equal(en_result, zh_result)


def test_all_three_commands_use_gettext_not_hardcoded() raises:
    set_locale("zh_CN")
    var examples_cmd = create_examples_command()
    var version_cmd = create_version_command()
    var genconfig_cmd = create_generate_config_command()

    assert_true("样例" in examples_cmd.description)
    assert_true("版本" in version_cmd.description)
    assert_true("配置" in genconfig_cmd.description)

    set_locale("en_US")
    var examples_cmd_en = create_examples_command()
    var version_cmd_en = create_version_command()
    var genconfig_cmd_en = create_generate_config_command()

    assert_true("Generate" in examples_cmd_en.description)
    assert_true("Version" in version_cmd_en.description)
    assert_true("config" in genconfig_cmd_en.description)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
