import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AccountsReceivableService } from './accounts-receivable.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Accounts Receivable')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('accounts-receivable')
export class AccountsReceivableController {
  constructor(private readonly service: AccountsReceivableService) {}

  @Get()
  @ApiOperation({ summary: 'Listar cuentas por cobrar' })
  findAll(@Query('storeId') storeId: string, @Query('pending') pending?: string) {
    return this.service.findAll(storeId, pending === 'true');
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener cuenta por cobrar' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Crear cuenta por cobrar' })
  create(@Body() dto: { storeId: string; clientId: string; orderId?: string; totalAmount: number; description?: string }) {
    return this.service.create(dto);
  }

  @Post(':id/payments')
  @ApiOperation({ summary: 'Registrar pago a cuenta' })
  addPayment(@Param('id') id: string, @Body() dto: { amount: number; paymentMethod?: string; notes?: string; collectedBy?: string }) {
    return this.service.addPayment(id, dto);
  }
}
