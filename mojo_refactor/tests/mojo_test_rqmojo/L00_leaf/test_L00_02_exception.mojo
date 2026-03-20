# test_L00_02_exception.mojo
# Module: rqmojo.utils.exception
# Python: rqalpha.utils.exception
# Level: L00 - Leaf module
# Dependencies: const

from rqmojo.utils.exception import (
    CustomError, RQUserError, RQInvalidArgument, RQTypeError,
    RQApiNotSupportedError, RQDatacVersionTooLow, InstrumentNotFound,
    EnvironmentNotInitialized, patch_user_exc, patch_system_exc,
    is_user_exc, is_system_exc
)
from rqmojo.const import EXC_TYPE


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

    fn test_custom_error(mut self):
        var error = CustomError.create("Test error message")
        self.check(error.msg == "Test error message", "CustomError.create msg")
        self.check(error.exc_type_name == "Exception", "CustomError.create exc_type_name")
        self.check(error.error_type == EXC_TYPE.NOTSET, "CustomError.create error_type")

    fn test_custom_error_str(mut self):
        var error = CustomError.create("Test error", "ValueError")
        var result = error.__str__()
        self.check(len(result) > 0, "CustomError.__str__ returns non-empty string")

    fn test_rq_user_error(mut self):
        var exc = RQUserError.create("User error occurred")
        self.check(exc.message == "User error occurred", "RQUserError.create message")
        self.check(exc.error_type == EXC_TYPE.USER_EXC, "RQUserError.create error_type")
        self.check(exc.__str__() == "User error occurred", "RQUserError.__str__")

    fn test_rq_user_error_to_error(mut self):
        var exc = RQUserError.create("Test error")
        var err = exc.to_error()
        self.check(True, "RQUserError.to_error returns Error")

    fn test_rq_invalid_argument(mut self):
        var exc = RQInvalidArgument.create("Invalid argument value")
        self.check(exc.message == "Invalid argument value", "RQInvalidArgument.create message")
        self.check(exc.__str__() == "RQInvalidArgument: Invalid argument value", "RQInvalidArgument.__str__")

    fn test_rq_invalid_argument_to_error(mut self):
        var exc = RQInvalidArgument.create("Test")
        var err = exc.to_error()
        self.check(True, "RQInvalidArgument.to_error returns Error")

    fn test_rq_type_error(mut self):
        var exc = RQTypeError.create("Type mismatch")
        self.check(exc.message == "Type mismatch", "RQTypeError.create message")
        self.check(exc.__str__() == "RQTypeError: Type mismatch", "RQTypeError.__str__")

    fn test_rq_type_error_to_error(mut self):
        var exc = RQTypeError.create("Test")
        var err = exc.to_error()
        self.check(True, "RQTypeError.to_error returns Error")

    fn test_rq_api_not_supported_error(mut self):
        var exc = RQApiNotSupportedError.create("API not supported")
        self.check(exc.message == "API not supported", "RQApiNotSupportedError.create message")
        self.check(exc.__str__() == "RQApiNotSupportedError: API not supported", "RQApiNotSupportedError.__str__")

    fn test_rq_api_not_supported_error_to_error(mut self):
        var exc = RQApiNotSupportedError.create("Test")
        var err = exc.to_error()
        self.check(True, "RQApiNotSupportedError.to_error returns Error")

    fn test_rq_datac_version_too_low(mut self):
        var exc = RQDatacVersionTooLow.create("Version 1.0 required")
        self.check(exc.message == "Version 1.0 required", "RQDatacVersionTooLow.create message")
        self.check(exc.__str__() == "RQDatacVersionTooLow: Version 1.0 required", "RQDatacVersionTooLow.__str__")

    fn test_rq_datac_version_too_low_to_error(mut self):
        var exc = RQDatacVersionTooLow.create("Test")
        var err = exc.to_error()
        self.check(True, "RQDatacVersionTooLow.to_error returns Error")

    fn test_instrument_not_found(mut self):
        var exc = InstrumentNotFound.create("000001.XSHE")
        self.check(exc.message == "Instrument 000001.XSHE not found", "InstrumentNotFound.create message")
        self.check(exc.__str__() == "InstrumentNotFound: Instrument 000001.XSHE not found", "InstrumentNotFound.__str__")

    fn test_instrument_not_found_to_error(mut self):
        var exc = InstrumentNotFound.create("000001.XSHE")
        var err = exc.to_error()
        self.check(True, "InstrumentNotFound.to_error returns Error")

    fn test_environment_not_initialized(mut self):
        var exc = EnvironmentNotInitialized.create()
        self.check(exc.message == "Environment has not been initialized", "EnvironmentNotInitialized.create message")
        self.check(exc.__str__() == "EnvironmentNotInitialized: Environment has not been initialized", "EnvironmentNotInitialized.__str__")

    fn test_environment_not_initialized_to_error(mut self):
        var exc = EnvironmentNotInitialized.create()
        var err = exc.to_error()
        self.check(True, "EnvironmentNotInitialized.to_error returns Error")

    fn test_patch_user_exc(mut self):
        var result = patch_user_exc(EXC_TYPE.NOTSET)
        self.check(result == EXC_TYPE.USER_EXC, "patch_user_exc returns USER_EXC for NOTSET")
        
        var result2 = patch_user_exc(EXC_TYPE.SYSTEM_EXC)
        self.check(result2 == EXC_TYPE.SYSTEM_EXC, "patch_user_exc keeps existing type")

    fn test_patch_system_exc(mut self):
        var result = patch_system_exc(EXC_TYPE.NOTSET)
        self.check(result == EXC_TYPE.SYSTEM_EXC, "patch_system_exc returns SYSTEM_EXC for NOTSET")
        
        var result2 = patch_system_exc(EXC_TYPE.USER_EXC)
        self.check(result2 == EXC_TYPE.USER_EXC, "patch_system_exc keeps existing type")

    fn test_is_user_exc(mut self):
        var result1 = is_user_exc(EXC_TYPE.USER_EXC)
        self.check(result1 == True, "is_user_exc returns True for USER_EXC")
        
        var result2 = is_user_exc(EXC_TYPE.SYSTEM_EXC)
        self.check(result2 == False, "is_user_exc returns False for SYSTEM_EXC")
        
        var result3 = is_user_exc(EXC_TYPE.NOTSET)
        self.check(result3 == False, "is_user_exc returns False for NOTSET")

    fn test_is_system_exc(mut self):
        var result1 = is_system_exc(EXC_TYPE.SYSTEM_EXC)
        self.check(result1 == True, "is_system_exc returns True for SYSTEM_EXC")
        
        var result2 = is_system_exc(EXC_TYPE.USER_EXC)
        self.check(result2 == False, "is_system_exc returns False for USER_EXC")
        
        var result3 = is_system_exc(EXC_TYPE.NOTSET)
        self.check(result3 == False, "is_system_exc returns False for NOTSET")

    fn test_exception_equality(mut self):
        var exc1 = RQUserError.create("test")
        var exc2 = RQUserError.create("test")
        self.check(exc1.message == exc2.message, "RQUserError message equality")

    fn run_all(mut self):
        print("=" * 60)
        print("L00_02_exception Module Tests")
        print("=" * 60)
        
        self.test_custom_error()
        self.test_custom_error_str()
        self.test_rq_user_error()
        self.test_rq_user_error_to_error()
        self.test_rq_invalid_argument()
        self.test_rq_invalid_argument_to_error()
        self.test_rq_type_error()
        self.test_rq_type_error_to_error()
        self.test_rq_api_not_supported_error()
        self.test_rq_api_not_supported_error_to_error()
        self.test_rq_datac_version_too_low()
        self.test_rq_datac_version_too_low_to_error()
        self.test_instrument_not_found()
        self.test_instrument_not_found_to_error()
        self.test_environment_not_initialized()
        self.test_environment_not_initialized_to_error()
        self.test_patch_user_exc()
        self.test_patch_system_exc()
        self.test_is_user_exc()
        self.test_is_system_exc()
        self.test_exception_equality()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
