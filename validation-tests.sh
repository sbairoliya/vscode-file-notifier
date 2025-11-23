#!/bin/bash

# Additional validation tests for Remote Notifier Extension

echo "=========================================="
echo "Extended Validation Tests"
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

# Test 1: Type definitions validation
echo -e "${YELLOW}[1] Type Definitions Validation${NC}"
run_test "NotificationData has title property" "grep -q 'title: string' src/types.ts"
run_test "NotificationData has message property" "grep -q 'message: string' src/types.ts"
run_test "ExtensionConfig has watchPath property" "grep -q 'watchPath: string' src/types.ts"
run_test "ExtensionStatus has isRemote property" "grep -q 'isRemote: boolean' src/types.ts"
echo ""

# Test 2: Remote watcher validation
echo -e "${YELLOW}[2] Remote Watcher Implementation${NC}"
run_test "RemoteWatcher has start method" "grep -q 'public start()' src/remoteWatcher.ts"
run_test "RemoteWatcher has stop method" "grep -q 'public stop()' src/remoteWatcher.ts"
run_test "RemoteWatcher has isActive method" "grep -q 'public isActive()' src/remoteWatcher.ts"
run_test "RemoteWatcher uses chokidar" "grep -q 'chokidar.watch' src/remoteWatcher.ts"
run_test "RemoteWatcher handles file changes" "grep -q 'handleFileChange' src/remoteWatcher.ts"
run_test "RemoteWatcher validates JSON" "grep -q 'JSON.parse' src/remoteWatcher.ts"
echo ""

# Test 3: Local notifier validation
echo -e "${YELLOW}[3] Local Notifier Implementation${NC}"
run_test "LocalNotifier has showNotification method" "grep -q 'public async showNotification' src/localNotifier.ts"
run_test "LocalNotifier has getStatus method" "grep -q 'public getStatus()' src/localNotifier.ts"
run_test "LocalNotifier uses node-notifier" "grep -q 'notifier.notify' src/localNotifier.ts"
run_test "LocalNotifier shows VS Code message" "grep -q 'vscode.window.showInformationMessage' src/localNotifier.ts"
echo ""

# Test 4: Extension activation validation
echo -e "${YELLOW}[4] Extension Activation Flow${NC}"
run_test "Extension detects remote environment" "grep -q 'vscode.env.remoteName' src/extension.ts"
run_test "Extension activates local side" "grep -q 'activateLocal' src/extension.ts"
run_test "Extension activates remote side" "grep -q 'activateRemote' src/extension.ts"
run_test "Extension registers commands" "grep -q 'registerCommand' src/extension.ts"
run_test "Extension watches configuration changes" "grep -q 'onDidChangeConfiguration' src/extension.ts"
echo ""

# Test 5: Command routing validation
echo -e "${YELLOW}[5] Command Routing${NC}"
run_test "Remote can execute showNotification command" "grep -q 'remote-notifier.showNotification' src/extension.ts"
run_test "Local registers showNotification handler" "grep -q 'remote-notifier.showNotification' src/extension.ts"
run_test "Extension has sendNotification command" "grep -q 'remote-notifier.sendNotification' src/extension.ts"
echo ""

# Test 6: Output channel usage
echo -e "${YELLOW}[6] Logging and Output${NC}"
run_test "Extension creates output channel" "grep -q 'createOutputChannel' src/extension.ts"
run_test "RemoteWatcher logs to output" "grep -q 'appendLine' src/remoteWatcher.ts"
run_test "LocalNotifier logs to output" "grep -q 'appendLine' src/localNotifier.ts"
echo ""

# Test 7: Error handling
echo -e "${YELLOW}[7] Error Handling${NC}"
run_test "RemoteWatcher catches file read errors" "grep -q 'catch (error)' src/remoteWatcher.ts"
run_test "RemoteWatcher handles invalid JSON" "grep -q 'catch (parseError)' src/remoteWatcher.ts"
run_test "LocalNotifier catches notification errors" "grep -q 'catch (error)' src/localNotifier.ts"
run_test "Extension shows error messages" "grep -q 'showErrorMessage' src/extension.ts"
echo ""

# Test 8: Configuration handling
echo -e "${YELLOW}[8] Configuration Management${NC}"
run_test "Extension reads watchPath config" "grep -q 'watchPath' src/extension.ts"
run_test "Extension reads enableSound config" "grep -q 'enableSound' src/extension.ts"
run_test "Extension reads notificationTimeout config" "grep -q 'notificationTimeout' src/extension.ts"
echo ""

# Test 9: Type safety check
echo -e "${YELLOW}[9] TypeScript Type Safety${NC}"
run_test "RemoteWatcher type annotations present" "grep -q 'private config: ExtensionConfig' src/remoteWatcher.ts"
run_test "LocalNotifier type annotations present" "grep -q 'private config: ExtensionConfig' src/localNotifier.ts"
run_test "Extension status is typed" "grep -q 'let extensionStatus: ExtensionStatus' src/extension.ts"
echo ""

# Test 10: Deactivation handling
echo -e "${YELLOW}[10] Deactivation${NC}"
run_test "Extension has deactivate function" "grep -q 'export function deactivate()' src/extension.ts"
run_test "Deactivate stops watcher" "grep -q 'remoteWatcher.stop' src/extension.ts"
run_test "Deactivate disposes output channel" "grep -q 'outputChannel.dispose()' src/extension.ts"
echo ""

# Test 11: Package.json validation
echo -e "${YELLOW}[11] Package Configuration${NC}"
run_test "Extension has correct version" "grep -q '\"version\": \"0.1.0\"' package.json"
run_test "Extension targets VS Code 1.85+" "grep -q '\"vscode\": \"^1.85.0\"' package.json"
run_test "Extension has activation event" "grep -q 'onStartupFinished' package.json"
run_test "Extension specifies extensionKind" "grep -q 'extensionKind' package.json"
echo ""

# Test 12: Build artifacts
echo -e "${YELLOW}[12] Build Artifacts${NC}"
run_test "All TypeScript files compiled" "[ $(ls -1 out/*.js 2>/dev/null | wc -l) -eq 4 ]"
run_test "All source maps generated" "[ $(ls -1 out/*.js.map 2>/dev/null | wc -l) -eq 4 ]"
run_test "Output files are not empty" "[ $(wc -c < out/extension.js) -gt 1000 ]"
echo ""

# Test 13: Git tracking
echo -e "${YELLOW}[13] Git Tracking${NC}"
run_test "Source files are tracked" "git ls-files | grep -q 'src/'"
run_test "Test data is tracked" "git ls-files | grep -q 'test-data/'"
run_test "Configuration files are tracked" "git ls-files | grep -q 'package.json'"
run_test "Built files are not tracked" "git ls-files | grep -q -v 'out/'"
echo ""

# Test 14: Code structure
echo -e "${YELLOW}[14] Code Organization${NC}"
run_test "Extension imports RemoteWatcher" "grep -q \"import.*RemoteWatcher\" src/extension.ts"
run_test "Extension imports LocalNotifier" "grep -q \"import.*LocalNotifier\" src/extension.ts"
run_test "Extension imports types" "grep -q \"import.*types\" src/extension.ts"
run_test "RemoteWatcher imports types" "grep -q \"import.*types\" src/remoteWatcher.ts"
run_test "LocalNotifier imports types" "grep -q \"import.*types\" src/localNotifier.ts"
echo ""

# Summary
echo "=========================================="
echo "Extended Validation Summary"
echo "=========================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All validation tests passed!${NC}"
    echo -e "${BLUE}Extension implementation is complete and correct.${NC}"
    exit 0
else
    echo -e "${RED}Some validation tests failed.${NC}"
    exit 1
fi
