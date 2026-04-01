import { Module } from '@nestjs/common';
import { VendorInventoriesController } from './vendor-inventories.controller';
import { VendorInventoriesService } from './vendor-inventories.service';
import { DatabaseModule } from '../../database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [VendorInventoriesController],
  providers: [VendorInventoriesService],
})
export class VendorInventoriesModule {}
