"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.StoreAccessGuard = void 0;
const common_1 = require("@nestjs/common");
let StoreAccessGuard = class StoreAccessGuard {
    canActivate(context) {
        var _a, _b, _c;
        const request = context.switchToHttp().getRequest();
        const user = request.user;
        if (!user)
            throw new common_1.ForbiddenException('No autenticado');
        // Master admins can access any store
        if (user.role === 'master-admin')
            return true;
        // Get storeId from params, query, or body
        const storeId = ((_a = request.params) === null || _a === void 0 ? void 0 : _a.storeId) ||
            ((_b = request.query) === null || _b === void 0 ? void 0 : _b.storeId) ||
            ((_c = request.body) === null || _c === void 0 ? void 0 : _c.storeId);
        if (!storeId)
            return true; // No store context, allow (controller will handle)
        // Check if user has access to this store
        const userStoreIds = user.storeIds || [];
        if (!userStoreIds.includes(storeId)) {
            throw new common_1.ForbiddenException('No tiene acceso a esta tienda');
        }
        return true;
    }
};
exports.StoreAccessGuard = StoreAccessGuard;
exports.StoreAccessGuard = StoreAccessGuard = __decorate([
    (0, common_1.Injectable)()
], StoreAccessGuard);
