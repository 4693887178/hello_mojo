#!/bin/bash

MOJO_BIN="/home/zhou/hello_mojo/trae_cn_78/.venv/bin/mojo"
PYTHON_BIN="/home/zhou/hello_mojo/trae_cn_78/.venv/bin/python"
PROJECT_ROOT="/home/zhou/hello_mojo/trae_cn_78"
TESTS_DIR="$PROJECT_ROOT/mojo_refactor/tests"
RESULTS_DIR="$TESTS_DIR/results"
LD_PRELOAD="/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so"
PYTHONPATH="$PROJECT_ROOT/.venv/lib/python3.14/site-packages"

MOJO_INCLUDES="-I rqmojo/third_party/argmojo/src -I rqmojo/third_party/EmberJson -I rqmojo/third_party/NuMojo -I rqmojo/third_party/mojo-yaml/src -I rqmojo/third_party/morrow.mojo"

run_python_test() {
    local group=$1
    local test_file=$2
    local test_path="$TESTS_DIR/python/$group/$test_file"
    if [ -f "$test_path" ]; then
        echo "Running Python test: $group/$test_file"
        cd "$PROJECT_ROOT"
        $PYTHON_BIN -m pytest "$test_path" -v --tb=short 2>&1
        return $?
    else
        echo "SKIP: Python test not found: $test_path"
        return 0
    fi
}

run_mojo_test() {
    local group=$1
    local test_file=$2
    local test_path="$TESTS_DIR/mojo/$group/$test_file"
    if [ -f "$test_path" ]; then
        echo "Running Mojo test: $group/$test_file"
        cd "$PROJECT_ROOT/mojo_refactor"
        LD_PRELOAD=$LD_PRELOAD PYTHONPATH=$PYTHONPATH $MOJO_BIN run $MOJO_INCLUDES "$test_path" 2>&1
        return $?
    else
        echo "SKIP: Mojo test not found: $test_path"
        return 0
    fi
}

echo "========================================"
echo "RQAlpha Mojo Refactoring Test Report"
echo "Generated: $(date)"
echo "========================================"
echo ""

mkdir -p "$RESULTS_DIR/group_01"
mkdir -p "$RESULTS_DIR/group_02"
mkdir -p "$RESULTS_DIR/group_03"
mkdir -p "$RESULTS_DIR/group_04"
mkdir -p "$RESULTS_DIR/group_05"
mkdir -p "$RESULTS_DIR/group_06"
mkdir -p "$RESULTS_DIR/group_07"
mkdir -p "$RESULTS_DIR/group_08"
mkdir -p "$RESULTS_DIR/group_09"

echo "=== Group 01 Tests ===" | tee "$RESULTS_DIR/group_01/summary.txt"
echo "" | tee -a "$RESULTS_DIR/group_01/summary.txt"

echo "Python Tests:" | tee -a "$RESULTS_DIR/group_01/summary.txt"
for test in "$TESTS_DIR/python/group_01"/*.py; do
    test_name=$(basename "$test")
    run_python_test "group_01" "$test_name" | tee -a "$RESULTS_DIR/group_01/summary.txt"
done

echo "" | tee -a "$RESULTS_DIR/group_01/summary.txt"
echo "Mojo Tests:" | tee -a "$RESULTS_DIR/group_01/summary.txt"
for test in "$TESTS_DIR/mojo/group_01"/*.mojo; do
    test_name=$(basename "$test")
    run_mojo_test "group_01" "$test_name" | tee -a "$RESULTS_DIR/group_01/summary.txt"
done

echo ""
echo "=== Group 02 Tests ===" | tee "$RESULTS_DIR/group_02/summary.txt"
echo "" | tee -a "$RESULTS_DIR/group_02/summary.txt"

echo "Python Tests:" | tee -a "$RESULTS_DIR/group_02/summary.txt"
for test in "$TESTS_DIR/python/group_02"/*.py; do
    test_name=$(basename "$test")
    run_python_test "group_02" "$test_name" | tee -a "$RESULTS_DIR/group_02/summary.txt"
done

echo "" | tee -a "$RESULTS_DIR/group_02/summary.txt"
echo "Mojo Tests:" | tee -a "$RESULTS_DIR/group_02/summary.txt"
for test in "$TESTS_DIR/mojo/group_02"/*.mojo; do
    test_name=$(basename "$test")
    run_mojo_test "group_02" "$test_name" | tee -a "$RESULTS_DIR/group_02/summary.txt"
done

echo ""
echo "=== Test Summary ==="
echo "See individual group reports in $RESULTS_DIR/group_XX/summary.txt"
