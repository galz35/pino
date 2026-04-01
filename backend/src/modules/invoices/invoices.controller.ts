import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { InvoicesService } from './invoices.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Invoices')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('invoices')
export class InvoicesController {
  constructor(private readonly service: InvoicesService) {}

  @Post()
  @ApiOperation({ summary: 'Crear factura de proveedor (transaccional con stock y movimientos)' })
  create(@Body() dto: any) {
    return this.service.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar facturas' })
  findAll(
    @Query('storeId') storeId?: string,
    @Query('supplierId') supplierId?: string,
  ) {
    return this.service.findAll(storeId, supplierId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de una factura' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar estado de factura' })
  update(@Param('id') id: string, @Body() dto: { status?: string }) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar factura' })
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
