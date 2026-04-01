import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { ProductsService } from './products.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { StoreAccessGuard } from '../../common/guards/store-access.guard';

@ApiTags('Products')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, StoreAccessGuard)
@Controller('products')
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Post()
  @ApiOperation({ summary: 'Crear un producto en la tienda' })
  create(@Body() dto: any) {
    return this.productsService.create(dto);
  }

  @Post('import')
  @ApiOperation({ summary: 'Importación masiva de productos (Transaccional)' })
  importBulk(@Body() dto: { storeId: string; products: any[]; cashierName: string }) {
    return this.productsService.importBulk(dto);
  }

  @Get()
  @ApiQuery({ name: 'storeId', required: true })
  @ApiQuery({ name: 'search', required: false })
  @ApiQuery({ name: 'departmentId', required: false })
  @ApiQuery({ name: 'subDepartmentId', required: false })
  @ApiOperation({ summary: 'Listar productos con filtro de búsqueda y categorías' })
  findAll(
    @Query('storeId') storeId: string, 
    @Query('search') search?: string,
    @Query('departmentId') departmentId?: string,
    @Query('subDepartmentId') subDepartmentId?: string,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number
  ) {
    return this.productsService.findAll(storeId, search, departmentId, subDepartmentId, limit, offset);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de un producto' })
  findOne(@Param('id') id: string) {
    return this.productsService.findOne(id);
  }

  @Get('barcode/:barcode')
  @ApiOperation({ summary: 'Buscar producto por código de barras' })
  findByBarcode(@Query('storeId') storeId: string, @Param('barcode') barcode: string) {
    return this.productsService.findByBarcode(storeId, barcode);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar producto' })
  update(@Param('id') id: string, @Body() dto: any) {
    return this.productsService.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar producto (Desactivación lógica)' })
  remove(@Param('id') id: string) {
    return this.productsService.remove(id);
  }
}
