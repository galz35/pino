import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ReturnsService } from './returns.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Returns')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('returns')
export class ReturnsController {
  constructor(private readonly service: ReturnsService) {}

  @Post()
  @ApiOperation({ summary: 'Registrar devolución del rutero' })
  create(
    @Body()
    dto: {
      storeId: string;
      orderId: string;
      ruteroId: string;
      notes?: string;
      items: Array<{
        productId: string;
        quantityBulks: number;
        quantityUnits: number;
        unitPrice: number;
      }>;
    },
  ) {
    return this.service.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar devoluciones con filtros' })
  findAll(
    @Query('storeId') storeId?: string,
    @Query('ruteroId') ruteroId?: string,
    @Query('orderId') orderId?: string,
    @Query('fromDate') fromDate?: string,
    @Query('toDate') toDate?: string,
  ) {
    return this.service.findAll({ storeId, ruteroId, orderId, fromDate, toDate });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalle de devolución con items' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }
}
