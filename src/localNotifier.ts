import * as vscode from 'vscode';
import * as notifier from 'node-notifier';
import * as path from 'path';
import { NotificationData, ExtensionConfig } from './types';

export class LocalNotifier {
    private config: ExtensionConfig;
    private outputChannel: vscode.OutputChannel;
    private notificationCount: number = 0;
    private lastNotification: NotificationData | null = null;

    constructor(
        config: ExtensionConfig,
        outputChannel: vscode.OutputChannel
    ) {
        this.config = config;
        this.outputChannel = outputChannel;
    }

    public async showNotification(data: NotificationData): Promise<void> {
        this.outputChannel.appendLine(`Received notification request: ${JSON.stringify(data)}`);

        try {
            // Store for status
            this.notificationCount++;
            this.lastNotification = data;

            // Show native notification
            notifier.notify(
                {
                    title: data.title,
                    message: data.message,
                    sound: data.sound !== false && this.config.enableSound,
                    wait: false,
                    timeout: this.config.notificationTimeout,
                    // Optional: Add icon (macOS)
                    // icon: path.join(__dirname, '..', 'resources', 'icon.png'),
                },
                (error: Error | null, response: string) => {
                    if (error) {
                        this.outputChannel.appendLine(`Notification error: ${error}`);
                    } else {
                        this.outputChannel.appendLine(`Notification response: ${response}`);
                    }
                }
            );

            // Also show VS Code notification for debugging
            const action = await vscode.window.showInformationMessage(
                `${data.title}: ${data.message}`,
                'Dismiss'
            );

            this.outputChannel.appendLine(`Native notification sent successfully (#${this.notificationCount})`);

        } catch (error) {
            this.outputChannel.appendLine(`ERROR showing notification: ${error}`);
            vscode.window.showErrorMessage(`Notification error: ${error}`);
        }
    }

    public getStatus(): {
        count: number;
        lastNotification: NotificationData | null;
    } {
        return {
            count: this.notificationCount,
            lastNotification: this.lastNotification
        };
    }
}
