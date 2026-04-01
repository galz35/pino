import { Module } from '@nestjs/common';
import { ReturnsController } from './returns.controller';
import { ReturnsService } from './returns.service';
import { DatabaseModule } from '../../database/database.module';
import { EventsModule } from '../../common/events.module';

@Module({
  imports: [DatabaseModule, EventsModule],
  controllers: [ReturnsController],
  providers: [ReturnsService],
  exports: [ReturnsService],
})
export class ReturnsModule {}
