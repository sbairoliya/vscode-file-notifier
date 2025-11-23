# Remote Notifier

Send native OS notifications from your remote SSH workspace to your local machine.

## Features

- Watch a file/pipe on remote SSH for JSON notification data
- Automatically send native notifications to your local machine
- No port forwarding required
- Works seamlessly with VS Code's remote SSH connection

## Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Compile

```bash
npm run compile
```

### 3. Configure

Open VS Code settings and configure:

```json
{
  "remoteNotifier.watchPath": "/path/to/notifications.json",
  "remoteNotifier.enableSound": true,
  "remoteNotifier.notificationTimeout": 10
}
```

### 4. Test Locally

1. Press F5 to launch extension development host
2. Run command: "Remote Notifier: Send Test Notification"
3. Verify you see a native notification

### 5. Test Remotely

1. Connect to remote SSH host
2. Install extension in remote
3. Configure watch path (remote path)
4. Modify the watched file:

```bash
echo '{"title":"Test","message":"Hello from remote"}' > /path/to/notifications.json
```

5. Verify notification appears on local machine

## Usage

### From Command Line (Remote)

```bash
# Send notification
echo '{"title":"Build Complete","message":"Success!"}' > /path/to/notifications.json
```

### From Script (Remote)

```python
import json

notification = {
    "title": "Script Complete",
    "message": "Processing finished successfully",
    "sound": True
}

with open('/path/to/notifications.json', 'w') as f:
    json.dump(notification, f)
```

### Notification Format

```json
{
  "title": "Required - Notification title",
  "message": "Required - Notification message",
  "timestamp": 1234567890,
  "priority": "low|normal|high",
  "sound": true
}
```

## Commands

- `Remote Notifier: Send Test Notification` - Send a test notification
- `Remote Notifier: Show Status` - Show extension status

## Troubleshooting

### No notifications appearing

1. Check Output channel: "Remote Notifier"
2. Verify watch path is correct
3. Verify file permissions
4. Run "Show Status" command

### Remote not detecting changes

1. Verify you're connected to SSH
2. Check if file exists on remote
3. Try manually editing file
4. Check remote logs in Output channel

## Architecture

- **Remote Extension** (SSH side): Watches file for changes, parses JSON, sends command
- **Local Extension** (Mac side): Receives command, shows native notification
- **Communication**: VS Code automatically routes commands across SSH connection

## License

MIT
