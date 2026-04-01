import { useEffect, useState, useCallback } from 'react';
import { io, Socket } from 'socket.io-client';
import { toast } from '@/lib/swalert';

const SOCKET_URL = 'http://localhost:3010/events';

export const useRealTimeEvents = (storeId?: string) => {
  const [socket, setSocket] = useState<Socket | null>(null);
  const [lastEvent, setLastEvent] = useState<any>(null);
  const [connected, setConnected] = useState(false);

  useEffect(() => {
    const newSocket = io(SOCKET_URL, {
      transports: ['websocket'],
      autoConnect: true,
    });

    newSocket.on('connect', () => {
      setConnected(true);
      if (storeId) {
        newSocket.emit('join_store', storeId);
      }
    });

    newSocket.on('disconnect', () => {
      setConnected(false);
    });

    // Listen for Sync Updates (New Orders, Visits, etc.)
    newSocket.on('sync_update', (data) => {
      setLastEvent(data);
      _handleNotification(data);
    });

    // Specific Store Updates
    newSocket.on('store_update', (data) => {
      setLastEvent(data);
      _handleNotification(data);
    });

    setSocket(newSocket);

    return () => {
      newSocket.close();
    };
  }, [storeId]);

  const _handleNotification = (event: any) => {
    switch (event.type) {
      case 'NEW_ORDER':
        toast.success(
          '¡Nuevo Pedido!',
          `Se ha recibido una orden por C$ ${event.payload.total.toFixed(2)}`
        );
        break;
      case 'NEW_VISIT':
        toast.info(
          'Nueva Visita en Ruta',
          `El vendedor ha registrado una visita en: ${event.payload.clientId}`
        );
        break;
      default:
        break;
    }
  };

  return { socket, lastEvent, connected };
};
