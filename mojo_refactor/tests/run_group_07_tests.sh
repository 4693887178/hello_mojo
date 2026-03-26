#!/bin/bash
# Run all Group 07 Python and Mojo tests
# Group 07: Files with 3-4 dependencies

set -e

BASE_DIR="/home/zhou/hello_mojo/trae_cn_78"
MOJO_REFactor_DIR="$BASE_DIR/mojo_refactor"
PYTHON_TEST_DIR="$MOJO_REFactor_DIR/tests/python/group_07"
MOJO_TEST_DIR="$MOJO_REFactor_DIR/tests/mojo/group_07"
RESULT_DIR="$MOJO_REFactor_DIR/tests/results/group_07"
PYTHON_PATH="$BASE_DIR/.venv/lib/python3.14/site-packages"
MOJO_PATH="$BASE_DIR/.venv/bin/mojo"

# Create directories
mkdir -p "$PYTHON_TEST_DIR" "$MOJO_TEST_DIR" "$RESULT_DIR"

# Include paths for Mojo
INCLUDES="-I . -I rqmojo/third_party/argmojo/src -I rqmojo/third_party/EmberJson -I rqmojo/third_party/NuMojo -I rqmojo/third_party/mojo-yaml/src -I rqmojo/third_party/morrow.mojo"

# Environment for Mojo with Python interop
export LD_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so
export PYTHONPATH="$PYTHON_PATH"

echo "========================================"
echo "Group 07 Test Runner"
echo "========================================"
echo "Python Test Dir: $PYTHON_TEST_DIR"
echo "Mojo Test Dir: $MOJO_TEST_DIR"
echo "Result Dir: $RESULT_DIR"
echo ""

# Track results
declare -A PYTHON_RESULTS
declare -A MOJO_RESULTS

# Test files list
TEST_FILES=(
    "test_strategy_universe"
    "test_bar_dict_price_board"
    "test_analyser_init"
    "test_plot_utils"
    "test_risk_mod"
    "test_scheduler_mod"
    "test_slippage"
    "test_simulation_validator"
    "test_mod_utils"
    "test_mocking"
)

# Run Python tests
echo "=== Running Python Tests ==="
cd "$BASE_DIR"

for test_name in "${TEST_FILES[@]}"; do
    test_file="$PYTHON_TEST_DIR/${test_name}.py"
    
    if [ -f "$test_file" ]; then
        echo "Running $test_name.py..."
        
        result_file="$RESULT_DIR/${test_name}_python.md"
        echo "# Python Test: $test_name" > "$result_file"
        echo "" >> "$result_file"
        echo "Test Date: $(date)" >> "$result_file"
        echo "" >> "$result_file"
        echo "## Output" >> "$result_file"
        echo '```' >> "$result_file"
        
        $BASE_DIR/.venv/bin/python -m pytest "$test_file" -v >> "$result_file" 2>&1
        exit_code=$?
        
        echo '```' >> "$result_file"
        echo "" >> "$result_file"
        
        if [ $exit_code -eq 0 ]; then
            echo "Status: **PASSED**" >> "$result_file"
            PYTHON_RESULTS[$test_name]="PASSED"
            echo "  PASSED"
        else
            echo "Status: **FAILED**" >> "$result_file"
            PYTHON_RESULTS[$test_name]="FAILED"
            echo "  FAILED"
        fi
    else
        echo "Skipping $test_name.py (not found)"
        PYTHON_RESULTS[$test_name]="SKIP"
    fi
done

echo ""
echo "=== Running Mojo Tests ==="
cd "$MOJO_REFactor_DIR"

for test_name in "${TEST_FILES[@]}"; do
    test_file="$MOJO_TEST_DIR/${test_name}.mojo"
    
    if [ -f "$test_file" ]; then
        echo "Running $test_name.mojo..."
        
        result_file="$RESULT_DIR/${test_name}_mojo.md"
        echo "# Mojo Test: $test_name" > "$result_file"
        echo "" >> "$result_file"
        echo "Test Date: $(date)" >> "$result_file"
        echo "" >> "$result_file"
        echo "## Output" >> "$result_file"
        echo '```' >> "$result_file"
        
        $MOJO_PATH run $INCLUDES "$test_file" >> "$result_file" 2>&1
        exit_code=$?
        
        echo '```' >> "$result_file"
        echo "" >> "$result_file"
        
        if [ $exit_code -eq 0 ]; then
            echo "Status: **PASSED**" >> "$result_file"
            MOJO_RESULTS[$test_name]="PASSED"
            echo "  PASSED"
        else
            echo "Status: **FAILED**" >> "$result_file"
            MOJO_RESULTS[$test_name]="FAILED"
            echo "  FAILED"
        fi
    else
        echo "Skipping $test_name.mojo (not found)"
        MOJO_RESULTS[$test_name]="SKIP"
    fi
done

# Generate summary
echo ""
echo "=== Generating Summary ==="
summary_file="$RESULT_DIR/SUMMARY.md"

cat > "$summary_file" << 'EOF'
# Group 07 Test Summary

**Test Date:** $(date)

## Overview

Group 07 contains 10 files with 3-4 dependencies each.

| # | File | Dependencies |
|---|------|--------------|
| 1 | core/strategy_universe.py | 3 |
| 2 | data/bar_dict_price_board.py | 3 |
| 3 | mod/rqalpha_mod_sys_analyser/__init__.py | 3 |
| 4 | mod/rqalpha_mod_sys_analyser/plot/utils.py | 3 |
| 5 | mod/rqalpha_mod_sys_risk/mod.py | 3 |
| 6 | mod/rqalpha_mod_sys_scheduler/mod.py | 3 |
| 7 | mod/rqalpha_mod_sys_simulation/slippage.py | 3 |
| 8 | mod/rqalpha_mod_sys_simulation/validator.py | 3 |
| 9 | mod/utils.py | 3 |
| 10 | utils/testing/mocking.py | 3 |

## Test Results

| File | Python | Mojo | Notes |
|------|--------|------|-------|
EOF

python_passed=0
python_failed=0
python_skip=0
mojo_passed=0
mojo_failed=0
mojo_skip=0

for test_name in "${TEST_FILES[@]}"; do
    py_status="${PYTHON_RESULTS[$test_name]}"
    mj_status="${MOJO_RESULTS[$test_name]}"
    
    echo "| $test_name | $py_status | $mj_status | |" >> "$summary_file"
    
    case "$py_status" in
        PASSED) ((python_passed++)) ;;
        FAILED) ((python_failed++)) ;;
        SKIP) ((python_skip++)) ;;
    esac
    
    case "$mj_status" in
        PASSED) ((mojo_passed++)) ;;
        FAILED) ((mojo_failed++)) ;;
        SKIP) ((mojo_skip++)) ;;
    esac
done

cat >> "$summary_file" << EOF

## Statistics

### Python Tests
- Passed: $python_passed
- Failed: $python_failed
- Skipped: $python_skip
- Total: ${#TEST_FILES[@]}

### Mojo Tests
- Passed: $mojo_passed
- Failed: $mojo_failed
- Skipped: $mojo_skip
- Total: ${#TEST_FILES[@]}

## Detailed Reports

See individual test result files in this directory for detailed output.

## Notes

1. Python tests use pytest framework
2. Mojo tests use Mojo's built-in test runner
3. Tests verify class structure, methods, and basic functionality
EOF

echo ""
echo "=== Final Summary ==="
echo "Python: $python_passed passed, $python_failed failed, $python_skip skipped"
echo "Mojo:   $mojo_passed passed, $mojo_failed failed, $mojo_skip skipped"
echo ""
echo "Results saved to: $RESULT_DIR"
