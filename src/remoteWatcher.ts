import * as vscode from 'vscode';
import * as chokidar from 'chokidar';
import * as fs from 'fs';
import * as path from 'path';
import { NotificationData, ExtensionConfig } from './types';

export class RemoteWatcher {
    private watcher: chokidar.FSWatcher | null = null;
    private config: ExtensionConfig;
    private outputChannel: vscode.OutputChannel;
    private lastProcessedContent: string = '';

    constructor(
        config: ExtensionConfig,
        outputChannel: vscode.OutputChannel
    ) {
        this.config = config;
        this.outputChannel = outputChannel;
    }

    public start(): void {
        if (!this.config.watchPath) {
            this.outputChannel.appendLine('ERROR: No watch path configured');
            vscode.window.showErrorMessage(
                'Remote Notifier: Please configure remoteNotifier.watchPath in settings'
            );
            return;
        }

        // Check if path exists
        if (!fs.existsSync(this.config.watchPath)) {
            this.outputChannel.appendLine(`WARNING: Watch path does not exist: ${this.config.watchPath}`);
            this.outputChannel.appendLine('Creating watch path...');

            try {
                // Create directory if it's a directory path, or create parent directory if it's a file
                const isDirectory = !this.config.watchPath.endsWith('.json');
                if (isDirectory) {
                    fs.mkdirSync(this.config.watchPath, { recursive: true });
                } else {
                    const dir = path.dirname(this.config.watchPath);
                    fs.mkdirSync(dir, { recursive: true });
                    fs.writeFileSync(this.config.watchPath, '{}');
                }
            } catch (err) {
                this.outputChannel.appendLine(`ERROR creating path: ${err}`);
                return;
            }
        }

        this.outputChannel.appendLine(`Starting file watcher on: ${this.config.watchPath}`);

        // Use chokidar for more reliable file watching
        this.watcher = chokidar.watch(this.config.watchPath, {
            persistent: true,
            ignoreInitial: false,
            awaitWriteFinish: {
                stabilityThreshold: 100,
                pollInterval: 50
            }
        });

        this.watcher.on('change', (path) => {
            this.outputChannel.appendLine(`File changed: ${path}`);
            this.handleFileChange(path);
        });

        this.watcher.on('add', (path) => {
            this.outputChannel.appendLine(`File added: ${path}`);
            this.handleFileChange(path);
        });

        this.watcher.on('error', (error) => {
            this.outputChannel.appendLine(`Watcher error: ${error}`);
        });

        this.outputChannel.appendLine('Remote watcher started successfully');
    }

    private handleFileChange(filePath: string): void {
        try {
            // Read file content
            const content = fs.readFileSync(filePath, 'utf8').trim();

            // Skip if empty or same as last processed
            if (!content || content === this.lastProcessedContent) {
                return;
            }

            this.lastProcessedContent = content;
            this.outputChannel.appendLine(`Processing content: ${content.substring(0, 100)}...`);

            // Try to parse as JSON
            let notificationData: NotificationData;

            try {
                notificationData = JSON.parse(content);
            } catch (parseError) {
                this.outputChannel.appendLine(`ERROR: Invalid JSON: ${parseError}`);
                return;
            }

            // Validate required fields
            if (!notificationData.title || !notificationData.message) {
                this.outputChannel.appendLine('ERROR: Missing required fields (title, message)');
                return;
            }

            // Add timestamp if not present
            if (!notificationData.timestamp) {
                notificationData.timestamp = Date.now();
            }

            // Add sound preference from config if not specified
            if (notificationData.sound === undefined) {
                notificationData.sound = this.config.enableSound;
            }

            this.outputChannel.appendLine(`Sending notification: ${JSON.stringify(notificationData)}`);

            // Send to local extension via command
            // This is the magic - VS Code automatically routes to local
            vscode.commands.executeCommand(
                'remote-notifier.showNotification',
                notificationData
            ).then(
                () => {
                    this.outputChannel.appendLine('Command executed successfully');
                },
                (error) => {
                    this.outputChannel.appendLine(`Command execution error: ${error}`);
                }
            );

        } catch (error) {
            this.outputChannel.appendLine(`ERROR handling file change: ${error}`);
        }
    }

    public stop(): void {
        if (this.watcher) {
            this.outputChannel.appendLine('Stopping remote watcher...');
            this.watcher.close();
            this.watcher = null;
        }
    }

    public isActive(): boolean {
        return this.watcher !== null;
    }
}
