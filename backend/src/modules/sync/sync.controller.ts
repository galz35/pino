import { Controller, Post, Get, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SyncService } from './sync.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Sync')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('sync')
export class SyncController {
  constructor(private readonly service: SyncService) {}

  @Get('statuses')
  @ApiOperation({ summary: 'Obtener el estado de sincronización de todas las tiendas' })
  getStatuses() {
    return this.service.getStatuses();
  }

  @Post('batch')
  @ApiOperation({ summary: 'Recibir una carga batch de operaciones offline' })
  processBatch(@Body() dto: { storeId: string; operations: any[] }) {
    return this.service.processBatchSync(dto.storeId, dto.operations);
  }
}
