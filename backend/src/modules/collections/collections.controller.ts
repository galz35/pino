import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { CollectionsService } from './collections.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Collections')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('collections')
export class CollectionsController {
  constructor(private readonly service: CollectionsService) {}

  @Post()
  @ApiOperation({ summary: 'Registrar cobro del rutero' })
  create(
    @Body()
    dto: {
      storeId: string;
      accountId?: string;
      ruteroId: string;
      clientId?: string;
      amount: number;
      paymentMethod?: string;
      notes?: string;
    },
  ) {
    return this.service.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar cobros con filtros' })
  findAll(
    @Query('storeId') storeId?: string,
    @Query('ruteroId') ruteroId?: string,
    @Query('clientId') clientId?: string,
    @Query('date') date?: string,
  ) {
    return this.service.findAll({ storeId, ruteroId, clientId, date });
  }

  @Get('summary')
  @ApiOperation({ summary: 'Resumen de cobros por rutero/fecha' })
  getSummary(
    @Query('storeId') storeId: string,
    @Query('ruteroId') ruteroId?: string,
    @Query('date') date?: string,
  ) {
    return this.service.getSummary({ storeId, ruteroId, date });
  }
}
