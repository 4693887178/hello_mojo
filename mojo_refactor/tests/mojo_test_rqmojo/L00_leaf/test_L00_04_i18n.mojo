# test_L00_04_i18n.mojo
# Module: rqmojo.utils.i18n
# Python: rqalpha.utils.i18n
# Level: L00 - Leaf module
# Dependencies: logger

from rqmojo.utils.i18n import gettext, set_locale, get_locale, I18n


@fieldwise_init
struct TestRunner:
    var test_count: Int
    var pass_count: Int
    
    fn check(mut self, condition: Bool, test_name: String):
        self.test_count += 1
        if condition:
            self.pass_count += 1
            print("PASS: " + test_name)
        else:
            print("FAIL: " + test_name)

    fn test_gettext_returns_string(mut self):
        var result = gettext("test message")
        self.check(result == "test message", "gettext returns the key")

    fn test_gettext_with_empty_string(mut self):
        var result = gettext("")
        self.check(result == "", "gettext with empty string")

    fn test_gettext_with_locale(mut self):
        var result = gettext("test", "en_US")
        self.check(result == "test", "gettext with locale parameter")

    fn test_set_locale(mut self):
        set_locale("zh_CN")
        self.check(True, "set_locale executes without error")

    fn test_get_locale(mut self):
        var result = get_locale()
        self.check(result == "zh_CN", "get_locale returns default locale")

    fn test_i18n_struct(mut self):
        var i18n = I18n(locale="zh_CN", translations=Dict[String, Dict[String, String]]())
        self.check(i18n.locale == "zh_CN", "I18n struct locale field")

    fn run_all(mut self):
        print("=" * 60)
        print("L00_04_i18n Module Tests")
        print("=" * 60)
        
        self.test_gettext_returns_string()
        self.test_gettext_with_empty_string()
        self.test_gettext_with_locale()
        self.test_set_locale()
        self.test_get_locale()
        self.test_i18n_struct()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
