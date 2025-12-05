import * as assert from 'assert';

// Test JSON parsing logic
function parseNotification(content: string): { title: string; message: string } | null {
    try {
        const data = JSON.parse(content.trim());
        if (data.title && data.message) return data;
        return null;
    } catch {
        return null;
    }
}

// Tests
console.log('Running file-watcher tests...');

// Valid JSON
assert.deepStrictEqual(
    parseNotification('{"title":"Test","message":"Hello"}'),
    { title: 'Test', message: 'Hello' }
);

// Missing title
assert.strictEqual(
    parseNotification('{"message":"Hello"}'),
    null
);

// Missing message
assert.strictEqual(
    parseNotification('{"title":"Test"}'),
    null
);

// Invalid JSON
assert.strictEqual(
    parseNotification('not json'),
    null
);

// Empty object
assert.strictEqual(
    parseNotification('{}'),
    null
);

// Whitespace handling
assert.deepStrictEqual(
    parseNotification('  {"title":"Test","message":"Hello"}  '),
    { title: 'Test', message: 'Hello' }
);

console.log('All file-watcher tests passed!');
