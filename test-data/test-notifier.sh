#!/bin/bash

# Test script to trigger notifications
NOTIFICATION_FILE="$1"

if [ -z "$NOTIFICATION_FILE" ]; then
    echo "Usage: $0 <path-to-notifications.json>"
    exit 1
fi

echo "Sending test notification to: $NOTIFICATION_FILE"

cat > "$NOTIFICATION_FILE" << EOF
{
  "title": "Test Alert",
  "message": "Test at $(date +%H:%M:%S)",
  "timestamp": $(date +%s)000,
  "priority": "normal",
  "sound": true
}
EOF

echo "Notification sent!"
