"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PendingDeliveriesModule = void 0;
const common_1 = require("@nestjs/common");
const pending_deliveries_controller_1 = require("./pending-deliveries.controller");
const pending_deliveries_service_1 = require("./pending-deliveries.service");
const database_module_1 = require("../../database/database.module");
let PendingDeliveriesModule = class PendingDeliveriesModule {
};
exports.PendingDeliveriesModule = PendingDeliveriesModule;
exports.PendingDeliveriesModule = PendingDeliveriesModule = __decorate([
    (0, common_1.Module)({
        imports: [database_module_1.DatabaseModule],
        controllers: [pending_deliveries_controller_1.PendingDeliveriesController],
        providers: [pending_deliveries_service_1.PendingDeliveriesService],
    })
], PendingDeliveriesModule);
