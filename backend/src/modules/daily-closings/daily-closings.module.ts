import { Module } from '@nestjs/common';
import { DailyClosingsController } from './daily-closings.controller';
import { DailyClosingsService } from './daily-closings.service';
import { DatabaseModule } from '../../database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [DailyClosingsController],
  providers: [DailyClosingsService],
  exports: [DailyClosingsService],
})
export class DailyClosingsModule {}
