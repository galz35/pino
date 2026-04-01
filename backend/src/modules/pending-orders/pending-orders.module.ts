import { Module } from '@nestjs/common';
import { PendingOrdersController } from './pending-orders.controller';
import { PendingOrdersService } from './pending-orders.service';
import { DatabaseModule } from '../../database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [PendingOrdersController],
  providers: [PendingOrdersService],
})
export class PendingOrdersModule {}
