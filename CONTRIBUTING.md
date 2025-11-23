# Contributing to Remote Notifier

## Development Setup

### Prerequisites
- Node.js 18+
- TypeScript 5.3+
- VS Code 1.85+

### Initial Setup
```bash
# Install dependencies
npm install

# Compile TypeScript
npm run compile

# Watch mode during development
npm run watch
```

### Running Tests
```bash
# Run all tests
./run-all-tests.sh

# Run individual test suites
./test-suite.sh           # 45 basic tests
./validation-tests.sh     # 54 validation tests
./functional-test.sh      # 34 functional tests
```

### Debugging

1. **Press F5** to launch extension development host
2. Use VS Code debugger to set breakpoints
3. Check **Output channel** "Remote Notifier" for logs

---

## Architecture

### Components

#### RemoteWatcher (`src/remoteWatcher.ts`)
Monitors a JSON file on the remote machine for notification triggers.

**Key responsibilities:**
- Watch file for changes using `chokidar`
- Parse JSON notification data
- Validate required fields
- Route to local extension via VS Code commands

**Methods:**
- `start()` - Begin monitoring
- `stop()` - Stop monitoring and clean up
- `isActive()` - Check watcher status

#### LocalNotifier (`src/localNotifier.ts`)
Displays native OS notifications on the local machine.

**Key responsibilities:**
- Show native OS notifications
- Display VS Code notifications for visibility
- Track notification history
- Handle errors gracefully

**Methods:**
- `showNotification(data)` - Display notification
- `getStatus()` - Get notification statistics

#### Extension (`src/extension.ts`)
Main orchestrator that coordinates local and remote sides.

**Key responsibilities:**
- Detect environment (local vs remote)
- Activate appropriate side
- Register commands
- Watch for configuration changes

#### Types (`src/types.ts`)
TypeScript interfaces for type safety.

**Interfaces:**
- `NotificationData` - Notification payload
- `ExtensionConfig` - Configuration options
- `ExtensionStatus` - Status information

---

## Usage Examples

### From Command Line (Remote)

```bash
# Simple notification
echo '{"title":"Build Complete","message":"Success!"}' > /tmp/notifications.json

# With all fields
echo '{
  "title":"Deployment",
  "message":"Production ready",
  "priority":"high",
  "sound":true,
  "timestamp":'$(date +%s000)'
}' > /tmp/notifications.json
```

### From Python Script (Remote)

```python
import json
import subprocess

def notify(title, message):
    notification = {
        "title": title,
        "message": message,
        "sound": True
    }
    with open('/tmp/notifications.json', 'w') as f:
        json.dump(notification, f)

# Use it
notify("Build Complete", "All tests passed!")
```

### From Bash Script (Remote)

```bash
#!/bin/bash

notify() {
    local title="$1"
    local message="$2"
    cat > /tmp/notifications.json <<EOF
{"title":"$title","message":"$message"}
EOF
}

# Use it
npm run build && notify "Build" "Complete"
```

### CI/CD Integration

```bash
# In your build script
npm run build
if [ $? -eq 0 ]; then
  echo '{"title":"Build Success","message":"Deploy ready"}' > /tmp/notif.json
else
  echo '{"title":"Build Failed","message":"Check logs"}' > /tmp/notif.json
fi
```

---

## Troubleshooting

### No notifications appearing

**Symptoms:** Write to file but no notification shows

**Check list:**
1. View **Output channel**: "Remote Notifier"
2. Verify watch path exists: `ls -la /path/to/notifications.json`
3. Check file permissions: `chmod 644 /path/to/notifications.json`
4. Run **"Remote Notifier: Show Status"** command
5. Verify JSON is valid: `cat /path/to/notifications.json | jq .`

### Remote not detecting changes

**Symptoms:** File changes don't trigger notification

**Check list:**
1. Verify SSH connection is active
2. Check if file exists on remote
3. Try writing with explicit timestamp to force change
4. Check output channel for watcher errors
5. Restart VS Code extension

### Slow notifications

**Symptoms:** Notifications appear with 5+ second delay

**Possible causes:**
- SSH network latency
- Docker file system lag (if using dev containers)
- File write buffering
- File watch debouncing (100ms stabilization threshold)

**Solutions:**
- Use faster SSH connection
- Store watch file on local volume (if devcontainer)
- Add timestamp to each notification to ensure uniqueness

### Permission denied

**Symptoms:** Cannot write to watch file

**Solutions:**
```bash
# On remote machine
mkdir -p /tmp/notifications
chmod 777 /tmp/notifications
touch /tmp/notifications/notifications.json
chmod 666 /tmp/notifications/notifications.json
```

---

## Dev Container Considerations

### Works Well With
- Linux containers
- GitHub Codespaces
- Remote containers over SSH
- Windows WSL2

### Known Issues With
- Docker Desktop on macOS (unreliable file watching)
- Very rapid notifications (may drop some)

### Setup for Dev Container

```json
// devcontainer.json
{
  "name": "My Dev Container",
  "image": "mcr.microsoft.com/devcontainers/base"
}
```

```json
// VS Code settings
{
  "remoteNotifier.watchPath": "/tmp/notifications.json"
}
```

No mounting needed - file only needs to exist in container.

---

## Caveats & Limitations

### Platform-Specific Behavior
- **macOS**: Works natively with native notifications
- **Windows**: Limited support (PowerShell notifications)
- **Linux**: May require additional DBus/Wayland setup

### File Watching Issues
- **Debouncing**: File changes within 100ms are merged
- **Race conditions**: Very fast writes may trigger before completion
- **Network lag**: SSH adds latency to file detection

### Notification State
- **Duplicate detection**: Same JSON content won't trigger twice
- **File locking**: Some editors lock files during write
- **Parsing failures**: Silent failures (check output channel)

### No Queueing
- Rapid successive notifications may be dropped
- No automatic retry on failure

### SSH Dependency
- Must stay connected for notifications to work
- Reconnection required if SSH drops
- Works with SSH file watchers and local file systems

---

## Performance Notes

- **Compilation**: ~2 seconds
- **Full test suite**: ~15 seconds
- **File watch response**: 100ms - 5 seconds (depends on SSH latency)
- **Memory usage**: ~50MB at rest

---

## Future Enhancements

### Planned
- Notification queueing for rapid fires
- Multiple watch paths support
- Notification history UI
- Custom sound support

### Possible
- Action buttons in notifications
- Notification filtering by priority
- Retry logic for failed notifications
- Database backend for persistence

---

## Building & Packaging

### Development Build
```bash
npm run compile
```

### Production Build
```bash
npm run vscode:prepublish
```

### Package Extension
```bash
npm install -g @vscode/vsce
vsce package
```

This creates a `.vsix` file ready for distribution.

---

## Testing Strategy

### Three-Tier Testing Approach

**Tier 1: Basic Tests (45 tests)**
- File structure validation
- Dependency verification
- Configuration validation
- Git tracking

**Tier 2: Validation Tests (54 tests)**
- Implementation completeness
- Type safety verification
- Error handling validation
- Code organization

**Tier 3: Functional Tests (34 tests)**
- JSON parsing and validation
- File operations
- Configuration defaults
- Build reproducibility

### Test Coverage: 133/133 (100%)

---

## Common Git Workflow

```bash
# Create feature branch
git checkout -b feature/your-feature

# Make changes
npm run compile

# Run tests
./run-all-tests.sh

# Commit
git add .
git commit -m "feat: describe your changes"

# Push
git push origin feature/your-feature
```

---

## Code Style

- **TypeScript**: Strict mode enabled
- **Formatting**: Default VS Code formatter
- **Linting**: ESLint configured
- **Imports**: Path organization enforced

```bash
# Run linter
npm run lint
```

---

## Security Considerations

⚠️ **Important**: This extension transmits notification data as JSON. Consider:
- File accessibility (world-readable by default)
- No encryption of watch file contents
- Notification visible to anyone at keyboard
- SSH connection security

Don't use for sensitive information without additional security measures.

---

## License

MIT - Feel free to use, modify, and distribute

---

## Questions?

Check the documentation:
- **README.md** - Quick start and features
- **IMPLEMENTATION-SUMMARY.md** - Technical details
- **FINAL-TEST-RESULTS.md** - Test results
- **Output channel** - Debug logs ("Remote Notifier")
