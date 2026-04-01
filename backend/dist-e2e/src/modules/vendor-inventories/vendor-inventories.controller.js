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
exports.VendorInventoriesController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const vendor_inventories_service_1 = require("./vendor-inventories.service");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
let VendorInventoriesController = class VendorInventoriesController {
    constructor(service) {
        this.service = service;
    }
    getInventory(vendorId, productId) {
        return this.service.getInventory(vendorId, productId);
    }
    getVendorProducts(vendorId) {
        return this.service.getVendorProducts(vendorId);
    }
    processTransaction(dto) {
        return this.service.processTransaction(dto);
    }
};
exports.VendorInventoriesController = VendorInventoriesController;
__decorate([
    (0, common_1.Get)(':vendorId/:productId'),
    (0, swagger_1.ApiOperation)({ summary: 'Obtener inventario de un producto asignado a un vendedor' }),
    __param(0, (0, common_1.Param)('vendorId')),
    __param(1, (0, common_1.Param)('productId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], VendorInventoriesController.prototype, "getInventory", null);
__decorate([
    (0, common_1.Get)(':vendorId'),
    (0, swagger_1.ApiOperation)({ summary: 'Listar productos asignados a un vendedor' }),
    __param(0, (0, common_1.Param)('vendorId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VendorInventoriesController.prototype, "getVendorProducts", null);
__decorate([
    (0, common_1.Post)('transaction'),
    (0, swagger_1.ApiOperation)({ summary: 'Procesar transacción de inventario de vendedor (asignar/devolver/vender)' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], VendorInventoriesController.prototype, "processTransaction", null);
exports.VendorInventoriesController = VendorInventoriesController = __decorate([
    (0, swagger_1.ApiTags)('Vendor Inventories'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('vendor-inventories'),
    __metadata("design:paramtypes", [vendor_inventories_service_1.VendorInventoriesService])
], VendorInventoriesController);
