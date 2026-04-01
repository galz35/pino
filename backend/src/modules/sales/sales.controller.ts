import { Controller, Post, Get, Body, Param, UseGuards, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SalesService } from './sales.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Sales')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('sales')
export class SalesController {
  constructor(private readonly service: SalesService) {}

  @Post('process')
  @ApiOperation({ summary: 'Procesar una venta (Transaccional puro)' })
  processSale(
    @Body()
    dto: {
      storeId: string;
      cashShiftId: string;
      cashierId: string;
      ticketNumber: string;
      items: Array<{ productId: string; quantity: number; unitPrice: number }>;
      paymentMethod: string;
    },
  ) {
    return this.service.processSale(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar ventas (Filtrable por tienda, turno y fecha)' })
  findAll(
    @Query('storeId') storeId?: string,
    @Query('storeIds') storeIds?: string,
    @Query('shiftId') shiftId?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string
  ) {
    return this.service.findAll(storeId, shiftId, startDate, endDate, storeIds);
  }

  @Get('dashboard-stats')
  @ApiOperation({ summary: 'Obtener métricas completas para el dashboard (Altamente optimizado)' })
  getDashboardStats(@Query('storeId') storeId: string) {
    return this.service.getDashboardStats(storeId);
  }

  @Get('report')
  @ApiOperation({ summary: 'Obtener reporte consolidado de ventas' })
  getReport(
    @Query('storeId') storeId: string,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string
  ) {
    return this.service.getSalesReport(storeId, startDate, endDate);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de una venta con sus items' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Post(':id/return')
  @ApiOperation({ summary: 'Procesar devolución de una venta' })
  processReturn(
    @Param('id') id: string,
    @Body() dto: { items: { productId: string; quantity: number }[]; reason?: string },
  ) {
    return this.service.processReturn(id, dto);
  }
}
