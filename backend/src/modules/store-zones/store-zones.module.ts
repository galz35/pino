import { Module } from '@nestjs/common';
import { StoreZonesController } from './store-zones.controller';
import { StoreZonesService } from './store-zones.service';
import { DatabaseModule } from '../../database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [StoreZonesController],
  providers: [StoreZonesService],
  exports: [StoreZonesService],
})
export class StoreZonesModule {}
