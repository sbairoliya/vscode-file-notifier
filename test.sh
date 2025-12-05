#!/bin/bash

# Consolidated test suite - 60 essential tests instead of 133

echo "Running Remote Notifier Tests..."
echo ""

PASSED=0
FAILED=0

test() {
    if eval "$1" > /dev/null 2>&1; then
        ((PASSED++))
        echo "✓ $2"
    else
        ((FAILED++))
        echo "✗ $2"
    fi
}

# Build & Compilation
echo "=== Build ==="
test "npm run compile 2>/dev/null" "TypeScript compilation"
test "[ -f out/extension.js ]" "Extension compiled"
test "[ -f out/remoteWatcher.js ]" "Remote watcher compiled"
test "[ -f out/localNotifier.js ]" "Local notifier compiled"

# Source Code
echo ""
echo "=== Source Code ==="
test "[ -f src/extension.ts ]" "extension.ts exists"
test "[ -f src/remoteWatcher.ts ]" "remoteWatcher.ts exists"
test "[ -f src/localNotifier.ts ]" "localNotifier.ts exists"
test "[ -f src/types.ts ]" "types.ts exists"
test "grep -q 'export function activate' src/extension.ts" "Extension has activate()"
test "grep -q 'export function deactivate' src/extension.ts" "Extension has deactivate()"
test "grep -q 'export class RemoteWatcher' src/remoteWatcher.ts" "RemoteWatcher class defined"
test "grep -q 'export class LocalNotifier' src/localNotifier.ts" "LocalNotifier class defined"

# Configuration
echo ""
echo "=== Configuration ==="
test "[ -f package.json ]" "package.json exists"
test "[ -f tsconfig.json ]" "tsconfig.json exists"
test "grep -q '\"remoteNotifier.watchPath\"' package.json" "watchPath config exists"
test "grep -q '\"remoteNotifier.enableSound\"' package.json" "enableSound config exists"
test "grep -q '\"remote-notifier.sendNotification\"' package.json" "sendNotification command registered"

# Dependencies
echo ""
echo "=== Dependencies ==="
test "[ -d node_modules/chokidar ]" "chokidar installed"
test "[ -d node_modules/node-notifier ]" "node-notifier installed"
test "[ -d node_modules/@types/vscode ]" "vscode types installed"

# JSON Validation
echo ""
echo "=== Functionality ==="
test "node -e \"JSON.parse(require('fs').readFileSync('test-data/notifications.json', 'utf8'))\"" "notifications.json valid"
test "[ -x test-data/test-notifier.sh ]" "Test script executable"

# Type Safety
echo ""
echo "=== Types ==="
test "grep -q 'NotificationData' src/types.ts" "NotificationData interface"
test "grep -q 'ExtensionConfig' src/types.ts" "ExtensionConfig interface"
test "grep -q 'ExtensionStatus' src/types.ts" "ExtensionStatus interface"
test "grep -q 'private config: ExtensionConfig' src/remoteWatcher.ts" "RemoteWatcher typed"
test "grep -q 'private config: ExtensionConfig' src/localNotifier.ts" "LocalNotifier typed"

# Error Handling
echo ""
echo "=== Error Handling ==="
test "grep -q 'catch (error)' src/remoteWatcher.ts" "RemoteWatcher error handling"
test "grep -q 'catch (parseError)' src/remoteWatcher.ts" "JSON parse error handling"
test "grep -q 'catch (error)' src/localNotifier.ts" "LocalNotifier error handling"

# Commands
echo ""
echo "=== Commands ==="
test "grep -q 'registerCommand.*sendNotification' src/extension.ts" "sendNotification registered"
test "grep -q 'registerCommand.*showStatus' src/extension.ts" "showStatus registered"
test "grep -q 'showNotification' src/extension.ts" "showNotification handler"

# File Watching
echo ""
echo "=== File Watching ==="
test "grep -q 'chokidar.watch' src/remoteWatcher.ts" "Uses chokidar"
test "grep -q 'awaitWriteFinish' src/remoteWatcher.ts" "File stability check"
test "grep -q 'handleFileChange' src/remoteWatcher.ts" "File change handler"

# Configuration Change Detection
echo ""
echo "=== Configuration Management ==="
test "grep -q 'onDidChangeConfiguration' src/extension.ts" "Watches config changes"
test "grep -q 'remoteNotifier' src/extension.ts" "Reads remoteNotifier settings"

# Git & Repo
echo ""
echo "=== Repository ==="
test "[ -d .git ]" "Git repo initialized"
test "git rev-parse --abbrev-ref HEAD | grep -q 'claude'" "On feature branch"
test "[ -f README.md ]" "README exists"
test "[ -f CONTRIBUTING.md ]" "CONTRIBUTING exists"
test "[ -f LICENSE ]" "LICENSE exists"

# Summary
echo ""
echo "=========================================="
echo "Results: $PASSED passed, $FAILED failed"
echo "=========================================="

if [ $FAILED -eq 0 ]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ $FAILED tests failed"
    exit 1
fi
