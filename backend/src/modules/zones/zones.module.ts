import { Module } from '@nestjs/common';
import { ZonesController, SubZonesController } from './zones.controller';
import { ZonesService } from './zones.service';
import { DatabaseModule } from '../../database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [ZonesController, SubZonesController],
  providers: [ZonesService],
  exports: [ZonesService],
})
export class ZonesModule {}
