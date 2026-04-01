import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { InventoryService } from './inventory.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Inventory')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('inventory')
export class InventoryController {
  constructor(private readonly service: InventoryService) {}

  @Post('adjust')
  @ApiOperation({ summary: 'Ajustar stock de un producto' })
  adjustStock(
    @Body()
    dto: {
      storeId: string;
      productId: string;
      userId: string;
      type: 'IN' | 'OUT';
      quantity: number;
      reference: string;
    },
  ) {
    return this.service.adjustStock(dto);
  }

  @Get('movements')
  @ApiOperation({ summary: 'Obtener historial de movimientos de inventario' })
  getMovements(
    @Query('storeId') storeId: string,
    @Query('date') date?: string,
    @Query('type') type?: string,
  ) {
    return this.service.getMovements(storeId, date, type);
  }
}
