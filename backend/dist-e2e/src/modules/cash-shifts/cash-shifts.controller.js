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
exports.CashShiftsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const cash_shifts_service_1 = require("./cash-shifts.service");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
let CashShiftsController = class CashShiftsController {
    constructor(service) {
        this.service = service;
    }
    openShift(dto) {
        return this.service.openShift(dto.storeId, dto.userId, dto.startingCash);
    }
    closeShift(dto) {
        return this.service.closeShift(dto.shiftId, dto.storeId, dto.expectedCash, dto.difference, dto.userId);
    }
    getActiveShift(storeId) {
        return this.service.getActiveShift(storeId);
    }
    getStats(id) {
        return this.service.getShiftStats(id);
    }
    findAll(storeId, status, cashierId) {
        return this.service.findAll(storeId, status, cashierId);
    }
    findOne(id) {
        return this.service.findOne(id);
    }
    closeShiftById(id, dto) {
        return this.service.closeShift(id, dto.storeId, dto.expectedCash, dto.difference, dto.userId);
    }
};
exports.CashShiftsController = CashShiftsController;
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Abrir un nuevo turno de caja' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], CashShiftsController.prototype, "openShift", null);
__decorate([
    (0, common_1.Post)('close'),
    (0, swagger_1.ApiOperation)({ summary: 'Cerrar un turno de caja' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], CashShiftsController.prototype, "closeShift", null);
__decorate([
    (0, common_1.Get)('active'),
    (0, swagger_1.ApiOperation)({ summary: 'Obtener el turno de caja activo para una tienda' }),
    __param(0, (0, common_1.Query)('storeId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CashShiftsController.prototype, "getActiveShift", null);
__decorate([
    (0, common_1.Get)('stats/:id'),
    (0, swagger_1.ApiOperation)({ summary: 'Obtener estadísticas (totales) de un turno' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CashShiftsController.prototype, "getStats", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Listar todos los turnos de caja de una tienda' }),
    __param(0, (0, common_1.Query)('storeId')),
    __param(1, (0, common_1.Query)('status')),
    __param(2, (0, common_1.Query)('cashierId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", void 0)
], CashShiftsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Obtener un turno de caja específico por ID' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CashShiftsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Post)(':id/close'),
    (0, swagger_1.ApiOperation)({ summary: 'Cerrar un turno de caja por ID en URL' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], CashShiftsController.prototype, "closeShiftById", null);
exports.CashShiftsController = CashShiftsController = __decorate([
    (0, swagger_1.ApiTags)('CashShifts'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('cash-shifts'),
    __metadata("design:paramtypes", [cash_shifts_service_1.CashShiftsService])
], CashShiftsController);
