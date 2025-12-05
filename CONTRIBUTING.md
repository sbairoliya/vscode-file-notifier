# Contributing to Remote Notifier

## Development Setup

**Prerequisites:** Node.js 18+, TypeScript 5.3+, VS Code 1.85+

```bash
npm install
npm run compile
npm run watch      # Watch mode
```

## Running Tests

```bash
npm test           # Run all tests
```

## Architecture

**RemoteWatcher** (`src/remoteWatcher.ts`): Monitors JSON file on remote, parses notifications, routes to local

**LocalNotifier** (`src/localNotifier.ts`): Shows native OS notifications on local machine

**Extension** (`src/extension.ts`): Orchestrates both sides, detects environment, registers commands

**Types** (`src/types.ts`): TypeScript interfaces for type safety

## Troubleshooting

**No notifications appearing:**
1. Check Output channel: "Remote Notifier"
2. Verify watch path exists: `ls -la /path/to/file.json`
3. Verify permissions: `chmod 644 /path/to/file.json`
4. Run "Remote Notifier: Show Status" command

**Remote not detecting changes:**
1. Verify SSH connection is active
2. Check if file exists on remote
3. Try writing with explicit timestamp to force change
4. Check output channel for watcher errors

**Slow notifications:**
- SSH network latency is normal
- Docker file system lag (if using dev containers)
- File write buffering
- Add timestamp field to force unique JSON

## Caveats

- **Platform-specific:** macOS/Windows/Linux have different notification behavior
- **File watching:** 100ms debounce may be too aggressive for slow filesystems
- **SSH dependency:** Extension deactivates if SSH drops
- **No queueing:** Rapid notifications may be dropped
- **No retry:** Failed notifications don't automatically retry

## Commands

- `Remote Notifier: Send Test Notification` - Send test notification
- `Remote Notifier: Show Status` - Display extension status

## Testing

Run tests with:
```bash
npm test
```

Tests verify:
- TypeScript compilation
- File watching functionality
- JSON parsing and validation
- Configuration management
- Cross-boundary command routing
