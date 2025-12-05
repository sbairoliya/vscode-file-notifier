# Contributing

## Setup

```bash
npm run install:all
npm run compile
```

## Development

1. Open in VS Code
2. Press F5 to launch "Run Both Extensions"
3. Test commands in the Extension Development Host

## Architecture

Two extensions communicate via `vscode.commands.executeCommand()`:

- **local-notifier**: Registers `remote-notifier.showNotification` command, uses `node-notifier` for native notifications
- **file-watcher**: Watches JSON file, calls `showNotification` command when file changes

Cross-host communication works because:
- local-notifier has `"api": "none"` in package.json
- file-watcher has `extensionDependencies` on local-notifier

## Build

```bash
npm run build  # Compiles and packages both extensions
```

Produces:
- `packages/local-notifier/remote-notifier-local-0.1.0.vsix`
- `packages/file-watcher/remote-notifier-watcher-0.1.0.vsix`
