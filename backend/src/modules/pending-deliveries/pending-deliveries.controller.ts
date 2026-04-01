import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PendingDeliveriesService } from './pending-deliveries.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Pending Deliveries')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('pending-deliveries')
export class PendingDeliveriesController {
  constructor(private readonly service: PendingDeliveriesService) {}

  @Get()
  @ApiOperation({ summary: 'Listar entregas pendientes con filtros' })
  findAll(
    @Query('storeId') storeId?: string,
    @Query('status') status?: string,
    @Query('ruteroId') ruteroId?: string,
    @Query('unassigned') unassigned?: string,
  ) {
    return this.service.findAll({ storeId, status, ruteroId, unassigned: unassigned === 'true' });
  }

  @Post()
  @ApiOperation({ summary: 'Crear entrega pendiente' })
  create(@Body() dto: { storeId: string; orderId: string; clientId?: string; address?: string; notes?: string }) {
    return this.service.create(dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar estado de entrega' })
  update(@Param('id') id: string, @Body() dto: { status?: string; ruteroId?: string }) {
    return this.service.update(id, dto);
  }

  @Post('assign-route')
  @ApiOperation({ summary: 'Asignar ruta a entregas pendientes' })
  assignRoute(@Body() dto: { deliveryIds: string[]; ruteroId: string; date?: string }) {
    return this.service.assignRoute(dto);
  }
}
