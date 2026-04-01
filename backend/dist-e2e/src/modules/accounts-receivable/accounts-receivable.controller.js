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
exports.AccountsReceivableController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const accounts_receivable_service_1 = require("./accounts-receivable.service");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
let AccountsReceivableController = class AccountsReceivableController {
    constructor(service) {
        this.service = service;
    }
    findAll(storeId, pending) {
        return this.service.findAll(storeId, pending === 'true');
    }
    findOne(id) {
        return this.service.findOne(id);
    }
    create(dto) {
        return this.service.create(dto);
    }
    addPayment(id, dto) {
        return this.service.addPayment(id, dto);
    }
};
exports.AccountsReceivableController = AccountsReceivableController;
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Listar cuentas por cobrar' }),
    __param(0, (0, common_1.Query)('storeId')),
    __param(1, (0, common_1.Query)('pending')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], AccountsReceivableController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Obtener cuenta por cobrar' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AccountsReceivableController.prototype, "findOne", null);
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Crear cuenta por cobrar' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], AccountsReceivableController.prototype, "create", null);
__decorate([
    (0, common_1.Post)(':id/payments'),
    (0, swagger_1.ApiOperation)({ summary: 'Registrar pago a cuenta' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], AccountsReceivableController.prototype, "addPayment", null);
exports.AccountsReceivableController = AccountsReceivableController = __decorate([
    (0, swagger_1.ApiTags)('Accounts Receivable'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('accounts-receivable'),
    __metadata("design:paramtypes", [accounts_receivable_service_1.AccountsReceivableService])
], AccountsReceivableController);
