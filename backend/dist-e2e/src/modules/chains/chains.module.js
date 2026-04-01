"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ChainsModule = void 0;
const common_1 = require("@nestjs/common");
const chains_controller_1 = require("./chains.controller");
const chains_service_1 = require("./chains.service");
let ChainsModule = class ChainsModule {
};
exports.ChainsModule = ChainsModule;
exports.ChainsModule = ChainsModule = __decorate([
    (0, common_1.Module)({
        controllers: [chains_controller_1.ChainsController],
        providers: [chains_service_1.ChainsService],
        exports: [chains_service_1.ChainsService],
    })
], ChainsModule);
