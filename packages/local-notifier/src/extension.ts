import * as vscode from 'vscode';
import * as notifier from 'node-notifier';

interface NotificationData {
    title: string;
    message: string;
    sound?: boolean;
}

export function activate(context: vscode.ExtensionContext) {
    const config = vscode.workspace.getConfiguration('remoteNotifier');

    context.subscriptions.push(
        vscode.commands.registerCommand('remote-notifier.showNotification', (data: NotificationData) => {
            if (!data?.title || !data?.message) return;

            notifier.notify({
                title: data.title,
                message: data.message,
                sound: data.sound !== false && config.get<boolean>('enableSound', true)
            });
        }),

        vscode.commands.registerCommand('remote-notifier.test', () => {
            vscode.commands.executeCommand('remote-notifier.showNotification', {
                title: 'Test',
                message: 'Local notifier working!'
            });
        })
    );
}

export function deactivate() {}
