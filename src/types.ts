/**
 * Notification data structure
 * Must be JSON-serializable for cross-boundary communication
 */
export interface NotificationData {
    title: string;
    message: string;
    timestamp?: number;
    priority?: 'low' | 'normal' | 'high';
    sound?: boolean;
    actions?: string[];
}

/**
 * Extension configuration
 */
export interface ExtensionConfig {
    watchPath: string;
    enableSound: boolean;
    notificationTimeout: number;
}

/**
 * Status information for debugging
 */
export interface ExtensionStatus {
    isRemote: boolean;
    remoteName: string | undefined;
    watcherActive: boolean;
    watchPath: string | null;
    notificationsReceived: number;
    lastNotification: NotificationData | null;
    errors: string[];
}
