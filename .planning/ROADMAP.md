# ROADMAP.md

## Milestone: Group 06 测试整理与修复

### Phase 1: 验证 Group 06 测试修复
**Status**: 🔄 In Progress
**Dependencies**: None
**Files**: 
- `tests/results/group_06/*.md`
- `rqmojo/__main__.mojo`
- `rqmojo/api.mojo`
- `rqmojo/cmds/bundle.mojo`
- `rqmojo/cmds/entry.mojo`

**Tasks**:
- [ ] 运行 Python 测试验证
- [ ] 运行 Mojo 测试验证
- [ ] 确认所有修复生效

---

### Phase 2: 继续 Group 07 重构
**Status**: ⏳ Pending
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
- [ ] 创建 Python 测试文件
- [ ] 创建 Mojo 测试文件
- [ ] 实现重构代码
- [ ] 验证测试通过

---

### Phase 3: 继续 Group 08 重构
**Status**: ⏳ Pending
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

---

## Progress Summary

| Phase | Status | Progress |
|-------|--------|----------|
| Phase 1 | 🔄 In Progress | 0% |
| Phase 2 | ⏳ Pending | 0% |
| Phase 3 | ⏳ Pending | 0% |

**Overall Milestone Progress**: 0%
