# ROADMAP.md

## Milestone: Group 07 测试整理与修复

### Phase 1: 验证 Group 06 测试修复
**Status**: ✅ Completed
**Dependencies**: None
**Files**: 
- `tests/results/group_06/*.md`
- `rqmojo/__main__.mojo`
- `rqmojo/api.mojo`
- `rqmojo/cmds/bundle.mojo`
- `rqmojo/cmds/entry.mojo`

**Tasks**:
- [x] 运行 Python 测试验证 (70 passed)
- [x] 运行 Mojo 测试验证 (7 passed)
- [x] 确认所有修复生效

**Summary**: Group 06 测试修复完成，Python 70 passed, Mojo 7 passed

---

### Phase 2: 完成 Group 07 测试工作
**Status**: ✅ Completed
**Dependencies**: Phase 1
**Files**: Group 07 (依赖数量 3-4)

**Target Files**:
1. `core/strategy_universe.py`
2. `data/bar_dict_price_board.py`
3. `mod/rqalpha_mod_sys_analyser/__init__.py`
4. `mod/rqalpha_mod_sys_analyser/plot/utils.py`
5. `mod/rqalpha_mod_sys_risk/mod.py`
6. `mod/rqalpha_mod_sys_scheduler/mod.py`
7. `mod/rqalpha_mod_sys_simulation/slippage.py`
8. `mod/rqalpha_mod_sys_simulation/validator.py`
9. `mod/utils.py`
10. `utils/testing/mocking.py`

**Tasks**:
- [x] 创建 Python 测试文件 (10个)
- [x] 创建 Mojo 测试文件 (10个)
- [x] 修复所有失败测试
- [x] 验证测试通过 (67 passed, 100%)

**Summary**: Group 07 测试完成，Python 67 passed (100%)

---

### Phase 3: 开始 Group 08 重构
**Status**: ✅ Completed
**Dependencies**: Phase 2
**Files**: Group 08 (依赖数量 4)

**Target Files**:
1. `cmds/run.py`
2. `core/strategy_context.py`
3. `data/base_data_source/storage_interface.py`
4. `data/instruments_mixin.py`
5. `data/trading_dates_mixin.py`
6. `mod/__init__.py`
7. `mod/rqalpha_mod_sys_accounts/component_validator.py`
8. `mod/rqalpha_mod_sys_accounts/validator.py`
9. `mod/rqalpha_mod_sys_analyser/mod.py`
10. `mod/rqalpha_mod_sys_analyser/plot_store.py`

**Tasks**:
- [x] 创建 Python 测试文件 (10个)
- [x] 创建 Mojo 测试文件 (10个)
- [x] 实现重构代码 (已存在)
- [x] 验证测试通过 (Python: 139 passed)

**Summary**: Group 08 测试完成，Python 139 passed (100%)

---

## Progress Summary

| Phase | Status | Progress |
|-------|--------|----------|
| Phase 1 | ✅ Completed | 100% |
| Phase 2 | ✅ Completed | 100% |
| Phase 3 | 🔄 In Progress | 0% |

**Overall Milestone Progress**: 66%
