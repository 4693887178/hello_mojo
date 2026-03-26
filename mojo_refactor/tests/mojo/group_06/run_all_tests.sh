#!/bin/bash
# Run all Group 06 Mojo tests and save results

MOJO_PATH="/home/zhou/hello_mojo/trae_cn_78/.venv/bin/mojo"
TEST_DIR="/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06"
RESULT_DIR="/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/results/group_06"
BASE_DIR="/home/zhou/hello_mojo/trae_cn_78/mojo_refactor"

# Include paths
INCLUDES="-I . -I rqmojo/third_party/argmojo/src -I rqmojo/third_party/EmberJson -I rqmojo/third_party/NuMojo -I rqmojo/third_party/mojo-yaml/src -I rqmojo/third_party/morrow.mojo"

cd $BASE_DIR

echo "=== Group 06 Mojo Test Runner ==="
echo "Test Directory: $TEST_DIR"
echo "Result Directory: $RESULT_DIR"
echo ""

# Array to track results
declare -A RESULTS

# Test files
TEST_FILES=(
    "test_risk_mod_init.mojo"
    "test_risk_validators_init.mojo"
    "test_accounts_mod_init.mojo"
    "test_main_module.mojo"
    "test_api.mojo"
    "test_bundle.mojo"
    "test_mod_cmd.mojo"
    "test_execution_context.mojo"
    "test_executor.mojo"
    "test_strategy_loader.mojo"
)

for test_file in "${TEST_FILES[@]}"; do
    echo "Running $test_file..."
    test_name=$(basename "$test_file" .mojo)
    result_file="$RESULT_DIR/${test_name}.md"
    
    echo "# Test Result: $test_file" > "$result_file"
    echo "" >> "$result_file"
    echo "Test Date: $(date)" >> "$result_file"
    echo "" >> "$result_file"
    echo "## Test Output" >> "$result_file"
    echo '```' >> "$result_file"
    
    $MOJO_PATH run $INCLUDES "$TEST_DIR/$test_file" >> "$result_file" 2>&1
    exit_code=$?
    
    echo '```' >> "$result_file"
    echo "" >> "$result_file"
    echo "## Result" >> "$result_file"
    if [ $exit_code -eq 0 ]; then
        echo "Status: **PASSED**" >> "$result_file"
        RESULTS[$test_file]="PASSED"
        echo "  PASSED"
    else
        echo "Status: **FAILED**" >> "$result_file"
        RESULTS[$test_file]="FAILED"
        echo "  FAILED"
    fi
    echo ""
done

# Generate summary
echo "=== Generating Summary ==="
summary_file="$RESULT_DIR/SUMMARY.md"

echo "# Group 06 Test Summary" > "$summary_file"
echo "" >> "$summary_file"
echo "Test Date: $(date)" >> "$summary_file"
echo "" >> "$summary_file"
echo "## Test Results" >> "$summary_file"
echo "" >> "$summary_file"
echo "| File | Status |" >> "$summary_file"
echo "|------|--------|" >> "$summary_file"

passed=0
failed=0

for test_file in "${TEST_FILES[@]}"; do
    status="${RESULTS[$test_file]}"
    echo "| $test_file | $status |" >> "$summary_file"
    if [ "$status" == "PASSED" ]; then
        ((passed++))
    else
        ((failed++))
    fi
done

echo "" >> "$summary_file"
echo "## Summary Statistics" >> "$summary_file"
echo "" >> "$summary_file"
echo "- Total Tests: ${#TEST_FILES[@]}" >> "$summary_file"
echo "- Passed: $passed" >> "$summary_file"
echo "- Failed: $failed" >> "$summary_file"
echo "- Pass Rate: $(echo "scale=2; $passed * 100 / ${#TEST_FILES[@]}" | bc)%" >> "$summary_file"

echo ""
echo "=== Final Summary ==="
echo "Total: ${#TEST_FILES[@]}"
echo "Passed: $passed"
echo "Failed: $failed"
echo ""
echo "Results saved to: $RESULT_DIR"
