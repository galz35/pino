import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { VendorInventoriesService } from './vendor-inventories.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Vendor Inventories')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('vendor-inventories')
export class VendorInventoriesController {
  constructor(private readonly service: VendorInventoriesService) {}

  @Get(':vendorId/:productId')
  @ApiOperation({ summary: 'Obtener inventario de un producto asignado a un vendedor' })
  getInventory(@Param('vendorId') vendorId: string, @Param('productId') productId: string) {
    return this.service.getInventory(vendorId, productId);
  }

  @Get(':vendorId')
  @ApiOperation({ summary: 'Listar productos asignados a un vendedor' })
  getVendorProducts(@Param('vendorId') vendorId: string) {
    return this.service.getVendorProducts(vendorId);
  }

  @Post('transaction')
  @ApiOperation({ summary: 'Procesar transacción de inventario de vendedor (asignar/devolver/vender)' })
  processTransaction(@Body() dto: {
    vendorId: string; productId: string; storeId: string;
    type: 'ASSIGN' | 'RETURN' | 'SALE'; quantity: number; userId: string;
  }) {
    return this.service.processTransaction(dto);
  }
}
