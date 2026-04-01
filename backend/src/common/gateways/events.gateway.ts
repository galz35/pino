import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Injectable, Logger } from '@nestjs/common';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: 'events',
})
@Injectable()
export class EventsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger('EventsGateway');

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
  }

  // Broadcast a global sync event (From Mobile to Web)
  emitSyncUpdate(data: { type: string; payload: any; storeId?: string }) {
    this.logger.log(`Broadcasting sync event: ${data.type}`);
    // Emit to all connected Dashboards
    this.server.emit('sync_update', data);
    
    // If store-specific, emit to that room
    if (data.storeId) {
      this.server.to(`store_${data.storeId}`).emit('store_update', data);
    }
  }

  @SubscribeMessage('join_store')
  handleJoinStore(client: Socket, storeId: string) {
    this.logger.log(`Client ${client.id} joining room: store_${storeId}`);
    client.join(`store_${storeId}`);
    return { status: 'joined', room: `store_${storeId}` };
  }
}
