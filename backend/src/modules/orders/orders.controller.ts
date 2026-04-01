import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { OrdersService } from './orders.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Orders')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('orders')
export class OrdersController {
  constructor(private readonly service: OrdersService) {}

  @Post()
  @ApiOperation({ summary: 'Crear un nuevo pedido' })
  create(@Body() dto: {
    storeId: string;
    clientId?: string;
    clientName?: string;
    vendorId?: string;
    salesManagerName?: string;
    paymentType?: string;
    priceLevel?: number;
    items: { productId: string; quantity: number; unitPrice: number; presentation?: string; priceLevel?: number }[];
    notes?: string;
  }) {
    return this.service.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar pedidos con filtros' })
  findAll(
    @Query('storeId') storeId?: string,
    @Query('status') status?: string,
    @Query('vendorId') vendorId?: string,
    @Query('fromDate') fromDate?: string,
    @Query('toDate') toDate?: string,
  ) {
    return this.service.findAll({ storeId, status, vendorId, fromDate, toDate });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de un pedido' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Actualizar status de un pedido' })
  updateStatus(
    @Param('id') id: string,
    @Body() dto: { status: string; updatedBy?: string },
  ) {
    return this.service.updateStatus(id, dto.status, dto.updatedBy);
  }
}
