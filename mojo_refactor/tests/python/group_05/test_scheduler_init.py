"""
Test for rqalpha/mod/rqalpha_mod_sys_scheduler/__init__.py
"""


class TestSchedulerInit:
    """Test scheduler module initialization"""

    def test_load_mod_function_exists(self):
        """Test load_mod function exists"""
        from rqalpha.mod.rqalpha_mod_sys_scheduler import load_mod
        
        assert callable(load_mod)

    def test_load_mod_returns_scheduler_mod(self):
        """Test load_mod returns SchedulerMod instance"""
        from rqalpha.mod.rqalpha_mod_sys_scheduler import load_mod
        
        mod = load_mod()
        assert mod is not None
        assert hasattr(mod, 'start_up')
        assert hasattr(mod, 'tear_down')

    def test_mod_name(self):
        """Test module name"""
        from rqalpha.mod.rqalpha_mod_sys_scheduler import load_mod
        
        mod = load_mod()
        assert mod.__class__.__name__ == "SchedulerMod"


class TestSchedulerMod:
    """Test SchedulerMod"""

    def test_scheduler_mod_has_start_up(self):
        """Test SchedulerMod has start_up method"""
        from rqalpha.mod.rqalpha_mod_sys_scheduler.mod import SchedulerMod
        
        mod = SchedulerMod()
        assert hasattr(mod, 'start_up')
        assert callable(mod.start_up)

    def test_scheduler_mod_has_tear_down(self):
        """Test SchedulerMod has tear_down method"""
        from rqalpha.mod.rqalpha_mod_sys_scheduler.mod import SchedulerMod
        
        mod = SchedulerMod()
        assert hasattr(mod, 'tear_down')
        assert callable(mod.tear_down)
