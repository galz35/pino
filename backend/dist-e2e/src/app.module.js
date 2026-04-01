"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
// Modules
const auth_module_1 = require("./modules/auth/auth.module");
const users_module_1 = require("./modules/users/users.module");
const stores_module_1 = require("./modules/stores/stores.module");
const chains_module_1 = require("./modules/chains/chains.module");
const products_module_1 = require("./modules/products/products.module");
const departments_module_1 = require("./modules/departments/departments.module");
const sales_module_1 = require("./modules/sales/sales.module");
const inventory_module_1 = require("./modules/inventory/inventory.module");
const cash_shifts_module_1 = require("./modules/cash-shifts/cash-shifts.module");
const clients_module_1 = require("./modules/clients/clients.module");
const orders_module_1 = require("./modules/orders/orders.module");
const suppliers_module_1 = require("./modules/suppliers/suppliers.module");
const notifications_module_1 = require("./modules/notifications/notifications.module");
const database_module_1 = require("./database/database.module");
const sync_module_1 = require("./modules/sync/sync.module");
const authorizations_module_1 = require("./modules/authorizations/authorizations.module");
const zones_module_1 = require("./modules/zones/zones.module");
const licenses_module_1 = require("./modules/licenses/licenses.module");
const invoices_module_1 = require("./modules/invoices/invoices.module");
const config_module_1 = require("./modules/config/config.module");
const store_zones_module_1 = require("./modules/store-zones/store-zones.module");
const visit_logs_module_1 = require("./modules/visit-logs/visit-logs.module");
const vendor_inventories_module_1 = require("./modules/vendor-inventories/vendor-inventories.module");
const accounts_receivable_module_1 = require("./modules/accounts-receivable/accounts-receivable.module");
const pending_deliveries_module_1 = require("./modules/pending-deliveries/pending-deliveries.module");
const routes_module_1 = require("./modules/routes/routes.module");
const pending_orders_module_1 = require("./modules/pending-orders/pending-orders.module");
const errors_module_1 = require("./modules/errors/errors.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({ isGlobal: true }),
            database_module_1.DatabaseModule,
            auth_module_1.AuthModule,
            users_module_1.UsersModule,
            stores_module_1.StoresModule,
            chains_module_1.ChainsModule,
            products_module_1.ProductsModule,
            departments_module_1.DepartmentsModule,
            sales_module_1.SalesModule,
            inventory_module_1.InventoryModule,
            cash_shifts_module_1.CashShiftsModule,
            clients_module_1.ClientsModule,
            orders_module_1.OrdersModule,
            suppliers_module_1.SuppliersModule,
            notifications_module_1.NotificationsModule,
            sync_module_1.SyncModule,
            authorizations_module_1.AuthorizationsModule,
            zones_module_1.ZonesModule,
            licenses_module_1.LicensesModule,
            invoices_module_1.InvoicesModule,
            config_module_1.AppConfigModule,
            store_zones_module_1.StoreZonesModule,
            visit_logs_module_1.VisitLogsModule,
            vendor_inventories_module_1.VendorInventoriesModule,
            accounts_receivable_module_1.AccountsReceivableModule,
            pending_deliveries_module_1.PendingDeliveriesModule,
            routes_module_1.RoutesModule,
            pending_orders_module_1.PendingOrdersModule,
            errors_module_1.ErrorsModule,
        ],
    })
], AppModule);
