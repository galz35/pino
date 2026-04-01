/**
 * useOfflineOperation Hook
 * 
 * Custom hook for executing operations with offline support
 * Automatically enqueues operations when offline and processes them when online
 */


import { useState } from 'react';
import { syncService, type OperationType, type OperationPriority } from '@/lib/sync-service';
import { logError } from '@/lib/error-logger';

interface UseOfflineOperationOptions {
    storeId: string;
    type: OperationType;
    priority?: OperationPriority;
    onSuccess?: () => void;
    onError?: (error: Error) => void;
}

interface UseOfflineOperationReturn {
    execute: (operation: () => Promise<void>) => Promise<void>;
    isPending: boolean;
    error: Error | null;
}

export function useOfflineOperation(
    options: UseOfflineOperationOptions
): UseOfflineOperationReturn {
    const [isPending, setIsPending] = useState(false);
    const [error, setError] = useState<Error | null>(null);

    const execute = async (operation: () => Promise<void>) => {
        setIsPending(true);
        setError(null);

        try {
            const isOnline = syncService.getIsOnline();

            if (isOnline) {
                // Try to execute immediately
                try {
                    await operation();
                    options.onSuccess?.();
                } catch (execError: any) {
                    // If execution fails, enqueue for retry
                    await syncService.enqueuePendingOperation({
                        storeId: options.storeId,
                        type: options.type,
                        priority: options.priority || 'medium',
                        operation: operation.toString(), // Note: This is a simplified approach
                    });

                    throw execError;
                }
            } else {
                // Offline: enqueue immediately
                await syncService.enqueuePendingOperation({
                    storeId: options.storeId,
                    type: options.type,
                    priority: options.priority || 'medium',
                    operation: operation.toString(),
                });

                // Call success callback even when offline (operation is queued)
                options.onSuccess?.();
            }
        } catch (err: any) {
            const error = err instanceof Error ? err : new Error(String(err));
            setError(error);

            await logError(error, {
                location: 'use-offline-operation',
                additionalInfo: {
                    storeId: options.storeId,
                    type: options.type,
                },
            });

            options.onError?.(error);
            throw error;
        } finally {
            setIsPending(false);
        }
    };

    return {
        execute,
        isPending,
        error,
    };
}
