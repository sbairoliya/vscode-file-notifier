import * as assert from 'assert';

interface NotificationData {
    title: string;
    message: string;
    sound?: boolean;
}

// Test validation logic
function isValidNotification(data: unknown): data is NotificationData {
    return (
        typeof data === 'object' &&
        data !== null &&
        'title' in data &&
        'message' in data &&
        typeof (data as NotificationData).title === 'string' &&
        typeof (data as NotificationData).message === 'string'
    );
}

// Tests
console.log('Running local-notifier tests...');

// Valid notification
assert.strictEqual(
    isValidNotification({ title: 'Test', message: 'Hello' }),
    true
);

// With optional sound
assert.strictEqual(
    isValidNotification({ title: 'Test', message: 'Hello', sound: true }),
    true
);

// Missing title
assert.strictEqual(
    isValidNotification({ message: 'Hello' }),
    false
);

// Missing message
assert.strictEqual(
    isValidNotification({ title: 'Test' }),
    false
);

// Null
assert.strictEqual(
    isValidNotification(null),
    false
);

// Empty object
assert.strictEqual(
    isValidNotification({}),
    false
);

console.log('All local-notifier tests passed!');
