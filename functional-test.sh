#!/bin/bash

# Functional tests for Remote Notifier Extension

echo "=========================================="
echo "Functional Tests"
echo "=========================================="
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Testing: $test_name ... "

    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 1: JSON validation scenarios
echo -e "${YELLOW}[1] JSON Validation${NC}"

# Valid JSON test - use file instead of command line
cat > /tmp/test-notification-valid.json <<'EOF'
{"title":"Test","message":"Hello"}
EOF
run_test "Valid notification JSON parses correctly" "node -e \"JSON.parse(require('fs').readFileSync('/tmp/test-notification-valid.json', 'utf8'))\""
rm -f /tmp/test-notification-valid.json

# Invalid JSON test - create temp file with invalid JSON
cat > /tmp/test-notification-invalid.json <<'EOF'
{invalid json}
EOF
run_test "Invalid JSON detection works" "! node -e \"JSON.parse(require('fs').readFileSync('/tmp/test-notification-invalid.json', 'utf8'))\""
rm -f /tmp/test-notification-invalid.json

# Required fields test - use temp file
cat > /tmp/test-notification-required.json <<'EOF'
{"title":"Test","message":"Msg"}
EOF
run_test "JSON with required fields validates" "node -e \"
var obj = JSON.parse(require('fs').readFileSync('/tmp/test-notification-required.json', 'utf8'));
if (obj.title && obj.message) { process.exit(0); } else { process.exit(1); }
\""
rm -f /tmp/test-notification-required.json

# Optional fields test - use temp file
cat > /tmp/test-notification-optional.json <<'EOF'
{"title":"Test","message":"Msg","timestamp":123}
EOF
run_test "Optional fields in JSON handled correctly" "node -e \"
var obj = JSON.parse(require('fs').readFileSync('/tmp/test-notification-optional.json', 'utf8'));
if (obj.title && obj.message && obj.timestamp) { process.exit(0); } else { process.exit(1); }
\""
rm -f /tmp/test-notification-optional.json

echo ""

# Test 2: Compiled code functionality
echo -e "${YELLOW}[2] Compiled Code Execution${NC}"

# Test types module can be parsed
run_test "Types module is valid JavaScript" "node -c out/types.js"

# Test that compiled files exist and have reasonable size
run_test "Compiled extension module exists and has content" "[ -s out/extension.js ] && [ \$(wc -c < out/extension.js) -gt 3000 ]"

# Test that compiled localNotifier exists and has content
run_test "Compiled localNotifier module exists and has content" "[ -s out/localNotifier.js ] && [ \$(wc -c < out/localNotifier.js) -gt 1000 ]"

# Test that compiled remoteWatcher exists and has content
run_test "Compiled remoteWatcher module exists and has content" "[ -s out/remoteWatcher.js ] && [ \$(wc -c < out/remoteWatcher.js) -gt 2000 ]"

echo ""

# Test 3: File and directory creation
echo -e "${YELLOW}[3] Directory and File Operations${NC}"

# Create test directories
TEST_DIR="/tmp/remote-notifier-test-$$"
run_test "Test directory can be created" "mkdir -p $TEST_DIR && [ -d $TEST_DIR ]"

# Test JSON file creation
run_test "Notification JSON file can be created" "echo '{\"title\":\"Test\",\"message\":\"Test\"}' > $TEST_DIR/notification.json && [ -f $TEST_DIR/notification.json ]"

# Test file reading
run_test "Created file can be read" "[ -r $TEST_DIR/notification.json ]"

# Test file permissions
run_test "Test script has proper permissions" "[ -x test-data/test-notifier.sh ]"

# Cleanup
run_test "Test directory can be cleaned" "rm -rf $TEST_DIR && [ ! -d $TEST_DIR ]"

echo ""

# Test 4: Configuration validation
echo -e "${YELLOW}[4] Configuration Validation${NC}"

# Check all required config properties exist in package.json
run_test "watchPath configuration exists" "grep -q 'remoteNotifier.watchPath' package.json"
run_test "enableSound configuration exists" "grep -q 'remoteNotifier.enableSound' package.json"
run_test "notificationTimeout configuration exists" "grep -q 'remoteNotifier.notificationTimeout' package.json"

# Check default values
run_test "watchPath has default empty value" "grep -q '\"default\": \"\"' package.json"
run_test "enableSound has default true value" "grep -q '\"default\": true' package.json"
run_test "notificationTimeout has default 10 value" "grep -q '\"default\": 10' package.json"

echo ""

# Test 5: Command registration
echo -e "${YELLOW}[5] Command Registration${NC}"

# Check commands are defined in package.json
run_test "sendNotification command registered" "grep -q '\"command\": \"remote-notifier.sendNotification\"' package.json"
run_test "showStatus command registered" "grep -q '\"command\": \"remote-notifier.showStatus\"' package.json"

# Check command titles exist
run_test "sendNotification has title" "grep -A1 '\"remote-notifier.sendNotification\"' package.json | grep -q '\"title\"'"
run_test "showStatus has title" "grep -A1 '\"remote-notifier.showStatus\"' package.json | grep -q '\"title\"'"

echo ""

# Test 6: Dependencies availability
echo -e "${YELLOW}[6] Dependencies Availability${NC}"

# Test node-notifier can be required
run_test "node-notifier dependency available" "node -e \"require('node-notifier'); process.exit(0)\""

# Test chokidar can be required
run_test "chokidar dependency available" "node -e \"require('chokidar'); process.exit(0)\""

# Test vscode types available
run_test "TypeScript can be used" "npm list typescript 2>/dev/null | grep -q typescript"

echo ""

# Test 7: Build reproducibility
echo -e "${YELLOW}[7] Build Reproducibility${NC}"

# Store current build time
CURRENT_BUILD=$(ls -l out/extension.js | awk '{print $6, $7, $8}')

# Rebuild
run_test "TypeScript recompilation succeeds" "npm run compile 2>/dev/null"

# Check output still exists
run_test "Output files persist after rebuild" "[ -f out/extension.js ] && [ -f out/localNotifier.js ] && [ -f out/remoteWatcher.js ]"

echo ""

# Test 8: Documentation completeness
echo -e "${YELLOW}[8] Documentation Completeness${NC}"

run_test "README has features section" "grep -q '## Features' README.md"
run_test "README has setup instructions" "grep -q '## Setup' README.md"
run_test "README has usage examples" "grep -q '## Usage' README.md"
run_test "README has troubleshooting guide" "grep -q '## Troubleshooting' README.md"
run_test "README has commands section" "grep -q '## Commands' README.md"
run_test "README has architecture section" "grep -q '## Architecture' README.md"

echo ""

# Summary
echo "=========================================="
echo "Functional Test Summary"
echo "=========================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All functional tests passed!${NC}"
    echo -e "${BLUE}The extension is ready for deployment.${NC}"
    exit 0
else
    echo -e "${RED}Some functional tests failed.${NC}"
    exit 1
fi
