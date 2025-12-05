# Remote Notifier

Send native OS notifications from your remote SSH workspace to your local machine.

## Features

- 📢 Watch a JSON file on remote SSH for notification triggers
- 🔔 Native OS notifications on your local machine
- 🚀 No port forwarding required
- 🔗 Seamless VS Code Remote-SSH integration

## Quick Start

### 1. Install & Compile
```bash
npm install && npm run compile
```

### 2. Test Locally (F5)
1. Press **F5** to launch the extension development host
2. Run command: **"Remote Notifier: Send Test Notification"**
3. Verify notification appears

### 3. Test Remotely
1. Connect to SSH host via "Remote-SSH: Connect to Host"
2. Configure in VS Code settings:
   ```json
   {
     "remoteNotifier.watchPath": "/tmp/notifications.json"
   }
   ```
3. Trigger a notification:
   ```bash
   echo '{"title":"Test","message":"Hello"}' > /tmp/notifications.json
   ```
4. See notification on your local machine ✅

## Configuration

```json
{
  "remoteNotifier.watchPath": "/path/to/notifications.json",
  "remoteNotifier.enableSound": true,
  "remoteNotifier.notificationTimeout": 10
}
```

## Notification Format

```json
{
  "title": "Required - Your title",
  "message": "Required - Your message",
  "timestamp": 1234567890,
  "sound": true
}
```

## Commands

- `Remote Notifier: Send Test Notification` - Send a test notification
- `Remote Notifier: Show Status` - Show extension status

## Documentation

- **[CONTRIBUTING.md](./CONTRIBUTING.md)** - Development, testing, architecture, usage examples
- **[IMPLEMENTATION-SUMMARY.md](./IMPLEMENTATION-SUMMARY.md)** - Technical overview
- **[FINAL-TEST-RESULTS.md](./FINAL-TEST-RESULTS.md)** - Test results (133/133 passing)

## License

MIT
