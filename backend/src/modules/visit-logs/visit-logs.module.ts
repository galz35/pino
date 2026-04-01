import { Module } from '@nestjs/common';
import { VisitLogsController } from './visit-logs.controller';
import { VisitLogsService } from './visit-logs.service';
import { DatabaseModule } from '../../database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [VisitLogsController],
  providers: [VisitLogsService],
})
export class VisitLogsModule {}
