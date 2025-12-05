# Remote Notifier

Send native OS notifications from your remote SSH workspace to your local machine.

## Architecture

Two extensions that communicate via VS Code's cross-host command routing:

- **local-notifier** (`extensionKind: ["ui"]`) - Runs locally, shows notifications
- **file-watcher** (`extensionKind: ["workspace", "ui"]`) - Watches files, triggers notifications

## Quick Start

```bash
npm run install:all
npm run build
```

This produces two `.vsix` files in `packages/*/`.

## Usage

1. Install both `.vsix` extensions
2. Connect to remote SSH
3. Configure watch path:
   ```json
   { "remoteNotifier.watchPath": "/tmp/notifications.json" }
   ```
4. Trigger notification:
   ```bash
   echo '{"title":"Hello","message":"World"}' > /tmp/notifications.json
   ```

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `remoteNotifier.watchPath` | `""` | Path to watch for notification JSON |
| `remoteNotifier.enableSound` | `true` | Play sound with notifications |

## License

MIT
