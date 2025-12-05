import * as vscode from 'vscode';
import * as chokidar from 'chokidar';
import * as fs from 'fs';

let watcher: chokidar.FSWatcher | null = null;
let lastContent = '';

export function activate(context: vscode.ExtensionContext) {
    const config = vscode.workspace.getConfiguration('remoteNotifier');
    const watchPath = config.get<string>('watchPath', '');

    if (watchPath) {
        startWatcher(watchPath);
    }

    context.subscriptions.push(
        vscode.commands.registerCommand('remote-notifier.sendTest', () => {
            vscode.commands.executeCommand('remote-notifier.showNotification', {
                title: 'Test from Watcher',
                message: `Sent at ${new Date().toLocaleTimeString()}`
            });
        }),

        vscode.workspace.onDidChangeConfiguration(e => {
            if (e.affectsConfiguration('remoteNotifier.watchPath')) {
                const newPath = vscode.workspace.getConfiguration('remoteNotifier').get<string>('watchPath', '');
                stopWatcher();
                if (newPath) startWatcher(newPath);
            }
        }),

        { dispose: stopWatcher }
    );
}

function startWatcher(path: string) {
    if (!fs.existsSync(path)) {
        fs.writeFileSync(path, '{}');
    }

    watcher = chokidar.watch(path, {
        persistent: true,
        awaitWriteFinish: { stabilityThreshold: 100, pollInterval: 50 }
    });

    watcher.on('change', handleChange);
    watcher.on('add', handleChange);
}

function handleChange(filePath: string) {
    try {
        const content = fs.readFileSync(filePath, 'utf8').trim();
        if (!content || content === lastContent || content === '{}') return;

        lastContent = content;
        const data = JSON.parse(content);

        if (data.title && data.message) {
            vscode.commands.executeCommand('remote-notifier.showNotification', data);
        }
    } catch {}
}

function stopWatcher() {
    watcher?.close();
    watcher = null;
}

export function deactivate() {
    stopWatcher();
}
