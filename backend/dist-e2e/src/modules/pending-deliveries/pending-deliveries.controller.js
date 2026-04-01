"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PendingDeliveriesController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const pending_deliveries_service_1 = require("./pending-deliveries.service");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
let PendingDeliveriesController = class PendingDeliveriesController {
    constructor(service) {
        this.service = service;
    }
    findAll(storeId, status, ruteroId, unassigned) {
        return this.service.findAll({ storeId, status, ruteroId, unassigned: unassigned === 'true' });
    }
    create(dto) {
        return this.service.create(dto);
    }
    update(id, dto) {
        return this.service.update(id, dto);
    }
    assignRoute(dto) {
        return this.service.assignRoute(dto);
    }
};
exports.PendingDeliveriesController = PendingDeliveriesController;
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Listar entregas pendientes con filtros' }),
    __param(0, (0, common_1.Query)('storeId')),
    __param(1, (0, common_1.Query)('status')),
    __param(2, (0, common_1.Query)('ruteroId')),
    __param(3, (0, common_1.Query)('unassigned')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String]),
    __metadata("design:returntype", void 0)
], PendingDeliveriesController.prototype, "findAll", null);
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Crear entrega pendiente' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], PendingDeliveriesController.prototype, "create", null);
__decorate([
    (0, common_1.Patch)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Actualizar estado de entrega' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], PendingDeliveriesController.prototype, "update", null);
__decorate([
    (0, common_1.Post)('assign-route'),
    (0, swagger_1.ApiOperation)({ summary: 'Asignar ruta a entregas pendientes' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], PendingDeliveriesController.prototype, "assignRoute", null);
exports.PendingDeliveriesController = PendingDeliveriesController = __decorate([
    (0, swagger_1.ApiTags)('Pending Deliveries'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('pending-deliveries'),
    __metadata("design:paramtypes", [pending_deliveries_service_1.PendingDeliveriesService])
], PendingDeliveriesController);
