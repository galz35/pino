"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.VisitLogsModule = void 0;
const common_1 = require("@nestjs/common");
const visit_logs_controller_1 = require("./visit-logs.controller");
const visit_logs_service_1 = require("./visit-logs.service");
const database_module_1 = require("../../database/database.module");
let VisitLogsModule = class VisitLogsModule {
};
exports.VisitLogsModule = VisitLogsModule;
exports.VisitLogsModule = VisitLogsModule = __decorate([
    (0, common_1.Module)({
        imports: [database_module_1.DatabaseModule],
        controllers: [visit_logs_controller_1.VisitLogsController],
        providers: [visit_logs_service_1.VisitLogsService],
    })
], VisitLogsModule);
