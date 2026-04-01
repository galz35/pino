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
exports.PendingOrdersController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const pending_orders_service_1 = require("./pending-orders.service");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
let PendingOrdersController = class PendingOrdersController {
    constructor(service) {
        this.service = service;
    }
    findAll(storeId, status) {
        return this.service.findAll(storeId, status);
    }
    create(dto) {
        return this.service.create(dto);
    }
    dispatch(dto) {
        return this.service.dispatch(dto);
    }
    updateStatus(id, dto) {
        return this.service.updateStatus(id, dto.status);
    }
};
exports.PendingOrdersController = PendingOrdersController;
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Listar pedidos pendientes de despacho' }),
    __param(0, (0, common_1.Query)('storeId')),
    __param(1, (0, common_1.Query)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], PendingOrdersController.prototype, "findAll", null);
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Crear pedido de despacho' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], PendingOrdersController.prototype, "create", null);
__decorate([
    (0, common_1.Post)('dispatch'),
    (0, swagger_1.ApiOperation)({ summary: 'Despachar pedidos' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], PendingOrdersController.prototype, "dispatch", null);
__decorate([
    (0, common_1.Patch)(':id/status'),
    (0, swagger_1.ApiOperation)({ summary: 'Actualizar estado de pedido' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], PendingOrdersController.prototype, "updateStatus", null);
exports.PendingOrdersController = PendingOrdersController = __decorate([
    (0, swagger_1.ApiTags)('Pending Orders'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('pending-orders'),
    __metadata("design:paramtypes", [pending_orders_service_1.PendingOrdersService])
], PendingOrdersController);
