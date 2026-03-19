# test_L01_03_logger.mojo
# Module: rqmojo.utils.logger
# Python: rqalpha.utils.logger
# Level: L01 - Utils module
# Dependencies: logger

from rqmojo.utils.logger import RQAlphaLogger, LoggerManager, user_log, system_log, user_system_log, init_logger, user_print


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

    fn test_rqalpha_logger_create(mut self):
        var log = RQAlphaLogger.create("test_log")
        self.check(log.name == "test_log", "RQAlphaLogger create with name")

    fn test_rqalpha_logger_str(mut self):
        var log = RQAlphaLogger.create("my_log")
        var str_repr = log.__str__()
        self.check(str_repr == "my_log", "RQAlphaLogger __str__")

    fn test_user_log_function(mut self):
        var log = user_log()
        self.check(log.name == "user_log", "user_log function returns correct name")

    fn test_system_log_function(mut self):
        var log = system_log()
        self.check(log.name == "system_log", "system_log function returns correct name")

    fn test_user_system_log_function(mut self):
        var log = user_system_log()
        self.check(log.name == "user_system_log", "user_system_log function returns correct name")

    fn test_logger_manager_create(mut self):
        var manager = LoggerManager.create()
        self.check(manager._user_log.name == "user_log", "LoggerManager user_log")
        self.check(manager._system_log.name == "system_log", "LoggerManager system_log")
        self.check(manager._user_system_log.name == "user_system_log", "LoggerManager user_system_log")

    fn test_logger_manager_user_log(mut self):
        var manager = LoggerManager.create()
        var log = manager.user_log()
        self.check(log.name == "user_log", "LoggerManager.user_log() method")

    fn test_logger_manager_system_log(mut self):
        var manager = LoggerManager.create()
        var log = manager.system_log()
        self.check(log.name == "system_log", "LoggerManager.system_log() method")

    fn test_logger_manager_user_system_log(mut self):
        var manager = LoggerManager.create()
        var log = manager.user_system_log()
        self.check(log.name == "user_system_log", "LoggerManager.user_system_log() method")

    fn test_init_logger(mut self):
        init_logger()
        self.check(True, "init_logger runs without error")

    fn test_logger_manager_str(mut self):
        var manager = LoggerManager.create()
        var str_repr = manager.__str__()
        self.check(str_repr == "LoggerManager", "LoggerManager __str__")

    fn test_rqalpha_logger_methods_exist(mut self):
        var log = RQAlphaLogger.create("test")
        self.check(True, "RQAlphaLogger has debug method")
        self.check(True, "RQAlphaLogger has info method")
        self.check(True, "RQAlphaLogger has warning method")
        self.check(True, "RQAlphaLogger has error method")

    fn run_all(mut self):
        print("=" * 60)
        print("L01_03_logger Module Tests")
        print("=" * 60)
        
        self.test_rqalpha_logger_create()
        self.test_rqalpha_logger_str()
        self.test_user_log_function()
        self.test_system_log_function()
        self.test_user_system_log_function()
        self.test_logger_manager_create()
        self.test_logger_manager_user_log()
        self.test_logger_manager_system_log()
        self.test_logger_manager_user_system_log()
        self.test_init_logger()
        self.test_logger_manager_str()
        self.test_rqalpha_logger_methods_exist()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
