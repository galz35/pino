import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PendingOrdersService } from './pending-orders.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Pending Orders')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('pending-orders')
export class PendingOrdersController {
  constructor(private readonly service: PendingOrdersService) {}

  @Get()
  @ApiOperation({ summary: 'Listar pedidos pendientes de despacho' })
  findAll(@Query('storeId') storeId: string, @Query('status') status?: string) {
    return this.service.findAll(storeId, status);
  }

  @Post()
  @ApiOperation({ summary: 'Crear pedido de despacho' })
  create(@Body() dto: {
    storeId: string; clientId?: string; clientName?: string;
    items: any[]; total?: number; notes?: string; paymentMethod?: string;
  }) {
    return this.service.create(dto);
  }

  @Post('dispatch')
  @ApiOperation({ summary: 'Despachar pedidos' })
  dispatch(@Body() dto: { orderIds: string[]; dispatchedBy: string }) {
    return this.service.dispatch(dto);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Actualizar estado de pedido' })
  updateStatus(@Param('id') id: string, @Body() dto: { status: string }) {
    return this.service.updateStatus(id, dto.status);
  }
}
