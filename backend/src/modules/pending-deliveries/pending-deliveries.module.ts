import { Module } from '@nestjs/common';
import { PendingDeliveriesController } from './pending-deliveries.controller';
import { PendingDeliveriesService } from './pending-deliveries.service';
import { DatabaseModule } from '../../database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [PendingDeliveriesController],
  providers: [PendingDeliveriesService],
})
export class PendingDeliveriesModule {}
