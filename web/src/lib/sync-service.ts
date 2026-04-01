/**
 * Sync Service for Offline Operations Management (Postgres Edition)
 * 
 * Handles queuing and synchronization of offline operations
 * pointing to the NestJS Batch API (/api/sync/batch).
 */

import { indexedDBService, type PendingOperation, type SyncStatus } from './indexed-db-service';
import apiClient from '../services/api-client';

const BATCH_SIZE = 15; 

export type OperationType = PendingOperation['type'];
export type OperationPriority = PendingOperation['priority'];

class SyncService {
    private isProcessing = false;
    private syncListeners: Map<string, Set<(status: SyncStatus) => void>> = new Map();
    private networkStatusListeners: Set<(isOnline: boolean) => void> = new Set();
    private isOnline = navigator.onLine;

    constructor() {
        this.initNetworkListeners();
    }

    private initNetworkListeners() {
        if (typeof window === 'undefined') return;

        window.addEventListener('online', () => this.updateOnlineStatus(true));
        window.addEventListener('offline', () => this.updateOnlineStatus(false));
        
        // Heartbeat cada 30s para verificar internet real
        setInterval(async () => {
            try {
                await fetch('/favicon.ico', { method: 'HEAD', cache: 'no-cache' });
                this.updateOnlineStatus(true);
            } catch (e) {
                this.updateOnlineStatus(false);
            }
        }, 30000);
    }

    private updateOnlineStatus(isOnline: boolean) {
        if (this.isOnline !== isOnline) {
            this.isOnline = isOnline;
            this.networkStatusListeners.forEach(cb => cb(isOnline));

            if (isOnline) {
                setTimeout(() => this.processPendingQueue(), 1000);
            }
        }
    }

    async enqueuePendingOperation(params: { storeId: string, type: OperationType, operation: any, priority?: OperationPriority }): Promise<string> {
        const operationId = `op_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`;

        const pendingOp: PendingOperation = {
            id: operationId,
            storeId: params.storeId,
            type: params.type,
            priority: params.priority || 'medium',
            operation: params.operation,
            timestamp: Date.now(),
            retryCount: 0,
            status: 'pending',
        };

        await indexedDBService.savePendingOperation(pendingOp);
        await this.updateStoreSyncStatus(params.storeId);

        if (this.isOnline && !this.isProcessing) {
            this.processPendingQueue();
        }

        return operationId;
    }

    async processPendingQueue(): Promise<void> {
        if (this.isProcessing || !this.isOnline) return;
        this.isProcessing = true;

        try {
            const allOps = await indexedDBService.getAllPendingOperations();
            const pendingOps = allOps.filter(op => op.status === 'pending' || op.status === 'failed');

            if (pendingOps.length === 0) {
                this.isProcessing = false;
                return;
            }

            // Agrupar por tienda para el Batch API
            const stores = Array.from(new Set(pendingOps.map(op => op.storeId)));

            for (const storeId of stores) {
                const storeOps = pendingOps.filter(op => op.storeId === storeId).slice(0, BATCH_SIZE);
                
                try {
                    // LLAMADA AL BATCH API DE NESTJS
                    await apiClient.post('/sync/batch', {
                        storeId,
                        operations: storeOps.map(op => ({
                            type: op.type,
                            data: op.operation,
                            localId: op.id
                        }))
                    });

                    // Si tiene éxito, eliminar de IndexedDB
                    for (const op of storeOps) {
                        await indexedDBService.removePendingOperation(op.id);
                    }
                } catch (error: any) {
                    for (const op of storeOps) {
                        await indexedDBService.updateOperationStatus(op.id, 'failed', error.message);
                    }
                }
                await this.updateStoreSyncStatus(storeId);
            }
        } catch (error) {
            console.error(error);
        } finally {
            this.isProcessing = false;
        }
    }

    private async updateStoreSyncStatus(storeId: string): Promise<void> {
        const pendingCount = await indexedDBService.getPendingCount(storeId);
        const failedCount = await indexedDBService.getFailedCount(storeId);

        const status: SyncStatus = {
            storeId,
            lastSyncTimestamp: Date.now(),
            pendingCount,
            failedCount,
            isOnline: this.isOnline,
        };

        await indexedDBService.updateSyncStatus(status);
        const listeners = this.syncListeners.get(storeId);
        if (listeners) listeners.forEach(cb => cb(status));
    }

    onSyncStatusChange(storeId: string, callback: (status: SyncStatus) => void) {
        if (!this.syncListeners.has(storeId)) this.syncListeners.set(storeId, new Set());
        this.syncListeners.get(storeId)!.add(callback);
        return () => this.syncListeners.get(storeId)?.delete(callback);
    }

    getIsOnline(): boolean {
        return this.isOnline;
    }
}

export const syncService = new SyncService();
