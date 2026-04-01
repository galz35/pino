import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly service: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar notificaciones' })
  findAll(
    @Query('storeId') storeId?: string,
    @Query('limit') limit?: string,
  ) {
    return this.service.findAll(storeId, limit ? parseInt(limit) : undefined);
  }

  @Post()
  @ApiOperation({ summary: 'Crear notificación (y broadcast via WebSocket)' })
  create(@Body() dto: {
    storeId: string;
    userId?: string;
    type: string;
    title: string;
    message: string;
    metadata?: any;
  }) {
    return this.service.create(dto);
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Marcar notificación como leída' })
  markAsRead(@Param('id') id: string) {
    return this.service.markAsRead(id);
  }

  @Patch('read-all')
  @ApiOperation({ summary: 'Marcar todas como leídas para una tienda' })
  markAllAsRead(@Body() dto: { storeId: string }) {
    return this.service.markAllAsRead(dto.storeId);
  }
}
