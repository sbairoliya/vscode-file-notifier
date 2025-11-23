#!/bin/bash

# Comprehensive test suite for Remote Notifier Extension

echo "=========================================="
echo "Remote Notifier Extension - Test Suite"
echo "=========================================="
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

# Test colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function to test
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

# Test 1: Check directory structure
echo -e "${YELLOW}[1] Directory Structure Tests${NC}"
run_test "src directory exists" "[ -d src ]"
run_test "test-data directory exists" "[ -d test-data ]"
run_test "out directory exists" "[ -d out ]"
run_test "node_modules directory exists" "[ -d node_modules ]"
echo ""

# Test 2: Check source files exist
echo -e "${YELLOW}[2] Source Files Tests${NC}"
run_test "extension.ts exists" "[ -f src/extension.ts ]"
run_test "remoteWatcher.ts exists" "[ -f src/remoteWatcher.ts ]"
run_test "localNotifier.ts exists" "[ -f src/localNotifier.ts ]"
run_test "types.ts exists" "[ -f src/types.ts ]"
echo ""

# Test 3: Check configuration files
echo -e "${YELLOW}[3] Configuration Files Tests${NC}"
run_test "package.json exists" "[ -f package.json ]"
run_test "tsconfig.json exists" "[ -f tsconfig.json ]"
run_test ".vscodeignore exists" "[ -f .vscodeignore ]"
run_test ".gitignore exists" "[ -f .gitignore ]"
echo ""

# Test 4: Check test data files
echo -e "${YELLOW}[4] Test Data Files Tests${NC}"
run_test "notifications.json exists" "[ -f test-data/notifications.json ]"
run_test "test-notifier.sh exists and is executable" "[ -x test-data/test-notifier.sh ]"
echo ""

# Test 5: Check compiled output
echo -e "${YELLOW}[5] Compiled Output Tests${NC}"
run_test "extension.js compiled" "[ -f out/extension.js ]"
run_test "remoteWatcher.js compiled" "[ -f out/remoteWatcher.js ]"
run_test "localNotifier.js compiled" "[ -f out/localNotifier.js ]"
run_test "types.js compiled" "[ -f out/types.js ]"
echo ""

# Test 6: Check source maps
echo -e "${YELLOW}[6] Source Maps Tests${NC}"
run_test "extension.js.map exists" "[ -f out/extension.js.map ]"
run_test "remoteWatcher.js.map exists" "[ -f out/remoteWatcher.js.map ]"
run_test "localNotifier.js.map exists" "[ -f out/localNotifier.js.map ]"
echo ""

# Test 7: Check package.json configuration
echo -e "${YELLOW}[7] Package Configuration Tests${NC}"
run_test "package.json has main field" "grep -q '\"main\"' package.json"
run_test "package.json has correct main path" "grep -q '\"main\": \"./out/extension.js\"' package.json"
run_test "package.json has commands" "grep -q '\"remote-notifier.sendNotification\"' package.json"
run_test "package.json has extension configuration" "grep -q '\"remoteNotifier.watchPath\"' package.json"
echo ""

# Test 8: Verify compiled code validity
echo -e "${YELLOW}[8] Compiled Code Validation${NC}"
run_test "extension.js is valid JavaScript" "node -c out/extension.js"
run_test "remoteWatcher.js is valid JavaScript" "node -c out/remoteWatcher.js"
run_test "localNotifier.js is valid JavaScript" "node -c out/localNotifier.js"
echo ""

# Test 9: Check dependencies
echo -e "${YELLOW}[9] Dependencies Tests${NC}"
run_test "node-notifier package installed" "[ -d node_modules/node-notifier ]"
run_test "chokidar package installed" "[ -d node_modules/chokidar ]"
run_test "vscode types available" "[ -d node_modules/@types/vscode ]"
echo ""

# Test 10: Verify notification.json structure
echo -e "${YELLOW}[10] Test Data Validation${NC}"
run_test "notifications.json is valid JSON" "node -e \"JSON.parse(require('fs').readFileSync('test-data/notifications.json', 'utf8'))\""
echo ""

# Test 11: Check README exists
echo -e "${YELLOW}[11] Documentation Tests${NC}"
run_test "README.md exists" "[ -f README.md ]"
run_test "README has usage section" "grep -q 'Usage' README.md"
run_test "README has setup section" "grep -q 'Setup' README.md"
run_test "README has troubleshooting section" "grep -q 'Troubleshooting' README.md"
echo ""

# Test 12: TypeScript compilation success
echo -e "${YELLOW}[12] TypeScript Compilation Tests${NC}"
run_test "npm run compile succeeds" "npm run compile 2>/dev/null"
echo ""

# Test 13: File content validation
echo -e "${YELLOW}[13] File Content Tests${NC}"
run_test "extension.ts exports activate function" "grep -q 'export function activate' src/extension.ts"
run_test "extension.ts exports deactivate function" "grep -q 'export function deactivate' src/extension.ts"
run_test "RemoteWatcher class defined" "grep -q 'export class RemoteWatcher' src/remoteWatcher.ts"
run_test "LocalNotifier class defined" "grep -q 'export class LocalNotifier' src/localNotifier.ts"
run_test "NotificationData interface defined" "grep -q 'export interface NotificationData' src/types.ts"
echo ""

# Test 14: Git repository validation
echo -e "${YELLOW}[14] Git Repository Tests${NC}"
run_test "Git repository initialized" "[ -d .git ]"
run_test "Correct branch is checked out" "git rev-parse --abbrev-ref HEAD | grep -q 'claude/implement-thos'"
run_test "Files are committed" "git rev-list --count HEAD | grep -q -E '^[1-9]'"
echo ""

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
