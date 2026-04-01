import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ChainsService } from './chains.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

@ApiTags('Chains')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('chains')
export class ChainsController {
  constructor(private readonly chainsService: ChainsService) {}

  @Post()
  @Roles('master-admin')
  @ApiOperation({ summary: 'Crear una nueva cadena de tiendas (Solo Master Admin)' })
  create(@Body() dto: { name: string; logoUrl?: string; ownerName?: string; ownerEmail?: string }) {
    return this.chainsService.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar todas las cadenas' })
  findAll() {
    return this.chainsService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de una cadena' })
  findOne(@Param('id') id: string) {
    return this.chainsService.findOne(id);
  }

  @Patch(':id')
  @Roles('master-admin', 'chain-admin')
  @ApiOperation({ summary: 'Actualizar datos de una cadena' })
  update(@Param('id') id: string, @Body() dto: any) {
    return this.chainsService.update(id, dto);
  }

  @Delete(':id')
  @Roles('master-admin')
  @ApiOperation({ summary: 'Desactivar una cadena' })
  remove(@Param('id') id: string) {
    return this.chainsService.remove(id);
  }
}
