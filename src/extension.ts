import * as vscode from 'vscode';
import { RemoteWatcher } from './remoteWatcher';
import { LocalNotifier } from './localNotifier';
import { NotificationData, ExtensionConfig, ExtensionStatus } from './types';

let outputChannel: vscode.OutputChannel;
let remoteWatcher: RemoteWatcher | null = null;
let localNotifier: LocalNotifier | null = null;
let extensionStatus: ExtensionStatus;

export function activate(context: vscode.ExtensionContext) {
    outputChannel = vscode.window.createOutputChannel('Remote Notifier');
    outputChannel.show();
    outputChannel.appendLine('Remote Notifier activating...');

    // Determine if we're running remotely
    const isRemote = vscode.env.remoteName !== undefined;
    const remoteName = vscode.env.remoteName;

    // Initialize status
    extensionStatus = {
        isRemote,
        remoteName,
        watcherActive: false,
        watchPath: null,
        notificationsReceived: 0,
        lastNotification: null,
        errors: []
    };

    outputChannel.appendLine(`Running in: ${isRemote ? 'REMOTE' : 'LOCAL'} mode`);
    if (remoteName) {
        outputChannel.appendLine(`Remote name: ${remoteName}`);
    }

    // Get configuration
    const config = getConfig();

    if (isRemote) {
        activateRemote(context, config);
    } else {
        activateLocal(context, config);
    }

    // Register status command (works on both sides)
    context.subscriptions.push(
        vscode.commands.registerCommand('remote-notifier.showStatus', () => {
            showStatus();
        })
    );

    // Watch for configuration changes
    context.subscriptions.push(
        vscode.workspace.onDidChangeConfiguration((e) => {
            if (e.affectsConfiguration('remoteNotifier')) {
                outputChannel.appendLine('Configuration changed, reloading...');
                const newConfig = getConfig();

                if (isRemote && remoteWatcher) {
                    remoteWatcher.stop();
                    remoteWatcher = new RemoteWatcher(newConfig, outputChannel);
                    remoteWatcher.start();
                }
            }
        })
    );

    outputChannel.appendLine('Remote Notifier activated successfully');
}

function activateRemote(context: vscode.ExtensionContext, config: ExtensionConfig) {
    outputChannel.appendLine('=== REMOTE SIDE ACTIVATION ===');

    // Initialize remote watcher
    remoteWatcher = new RemoteWatcher(config, outputChannel);
    remoteWatcher.start();

    extensionStatus.watcherActive = remoteWatcher.isActive();
    extensionStatus.watchPath = config.watchPath;

    // Register test command
    context.subscriptions.push(
        vscode.commands.registerCommand('remote-notifier.sendNotification', async () => {
            outputChannel.appendLine('Sending test notification from remote...');

            const testData: NotificationData = {
                title: 'Test from Remote',
                message: `Sent at ${new Date().toLocaleTimeString()}`,
                timestamp: Date.now(),
                priority: 'normal',
                sound: true
            };

            try {
                await vscode.commands.executeCommand(
                    'remote-notifier.showNotification',
                    testData
                );
                vscode.window.showInformationMessage('Test notification sent!');
            } catch (error) {
                vscode.window.showErrorMessage(`Failed to send: ${error}`);
            }
        })
    );

    // Clean up on deactivation
    context.subscriptions.push({
        dispose: () => {
            if (remoteWatcher) {
                remoteWatcher.stop();
            }
        }
    });
}

function activateLocal(context: vscode.ExtensionContext, config: ExtensionConfig) {
    outputChannel.appendLine('=== LOCAL SIDE ACTIVATION ===');

    // Initialize local notifier
    localNotifier = new LocalNotifier(config, outputChannel);

    // Register command that remote will call
    context.subscriptions.push(
        vscode.commands.registerCommand(
            'remote-notifier.showNotification',
            async (data: NotificationData) => {
                outputChannel.appendLine('Command received from remote!');

                if (!localNotifier) {
                    outputChannel.appendLine('ERROR: Local notifier not initialized');
                    return;
                }

                await localNotifier.showNotification(data);

                // Update status
                const status = localNotifier.getStatus();
                extensionStatus.notificationsReceived = status.count;
                extensionStatus.lastNotification = status.lastNotification;
            }
        )
    );

    // Register local test command
    context.subscriptions.push(
        vscode.commands.registerCommand('remote-notifier.sendNotification', async () => {
            outputChannel.appendLine('Sending test notification locally...');

            if (!localNotifier) {
                vscode.window.showErrorMessage('Local notifier not initialized');
                return;
            }

            const testData: NotificationData = {
                title: 'Local Test',
                message: `Sent at ${new Date().toLocaleTimeString()}`,
                timestamp: Date.now(),
                priority: 'normal',
                sound: true
            };

            await localNotifier.showNotification(testData);
        })
    );
}

function getConfig(): ExtensionConfig {
    const config = vscode.workspace.getConfiguration('remoteNotifier');

    return {
        watchPath: config.get<string>('watchPath', ''),
        enableSound: config.get<boolean>('enableSound', true),
        notificationTimeout: config.get<number>('notificationTimeout', 10)
    };
}

function showStatus() {
    const statusMessage = `
Remote Notifier Status:
----------------------
Mode: ${extensionStatus.isRemote ? 'REMOTE' : 'LOCAL'}
Remote Name: ${extensionStatus.remoteName || 'N/A'}
Watcher Active: ${extensionStatus.watcherActive}
Watch Path: ${extensionStatus.watchPath || 'Not configured'}
Notifications Received: ${extensionStatus.notificationsReceived}
Last Notification: ${extensionStatus.lastNotification ?
        `${extensionStatus.lastNotification.title} - ${extensionStatus.lastNotification.message}` :
        'None'}
Errors: ${extensionStatus.errors.length}
    `.trim();

    outputChannel.appendLine('\n' + statusMessage);
    vscode.window.showInformationMessage('Status printed to output channel');
}

export function deactivate() {
    outputChannel.appendLine('Remote Notifier deactivating...');

    if (remoteWatcher) {
        remoteWatcher.stop();
    }

    outputChannel.dispose();
}
