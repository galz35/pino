import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { VisitLogsService } from './visit-logs.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Visit Logs')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('visit-logs')
export class VisitLogsController {
  constructor(private readonly service: VisitLogsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar logs de visitas de vendedores' })
  findAll(@Query('storeId') storeId: string, @Query('days') days?: string) {
    return this.service.findAll(storeId, days ? parseInt(days) : undefined);
  }

  @Post()
  @ApiOperation({ summary: 'Registrar una visita de vendedor' })
  create(@Body() dto: { storeId: string; vendorId: string; clientId: string; notes?: string; latitude?: number; longitude?: number }) {
    return this.service.create(dto);
  }
}
