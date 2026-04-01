import { Controller, Get, Post, Body, Param, Patch, Delete, UseGuards, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { DepartmentsService } from './departments.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { StoreAccessGuard } from '../../common/guards/store-access.guard';

@ApiTags('Departments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, StoreAccessGuard)
@Controller()
export class DepartmentsController {
  constructor(private readonly service: DepartmentsService) {}

  @Post('departments')
  @ApiOperation({ summary: 'Crear un nuevo departamento en la tienda' })
  create(@Body() dto: { name: string; storeId: string }) {
    return this.service.create(dto);
  }

  @Get('sub-departments')
  @ApiOperation({ summary: 'Obtener sub-departamentos (alias para el frontend)' })
  findSub(@Query('storeId') storeId: string) {
    return this.service.findAll(storeId, 'sub');
  }

  @Get('departments')
  @ApiOperation({ summary: 'Listar departamentos de una tienda' })
  findAll(@Query('storeId') storeId: string, @Query('type') type?: string) {
    return this.service.findAll(storeId, type);
  }


  @Delete('departments/:id')
  @ApiOperation({ summary: 'Eliminar departamento' })
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }

  @Patch('departments/:id')
  @ApiOperation({ summary: 'Actualizar departamento' })
  update(@Param('id') id: string, @Body() dto: { name: string }) {
    return this.service.update(id, dto);
  }
}
