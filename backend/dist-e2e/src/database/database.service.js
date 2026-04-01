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
var DatabaseService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.DatabaseService = void 0;
const common_1 = require("@nestjs/common");
const pg_1 = require("pg");
let DatabaseService = DatabaseService_1 = class DatabaseService {
    constructor(pool) {
        this.pool = pool;
        this.logger = new common_1.Logger(DatabaseService_1.name);
        this.pool.on('error', (err) => {
            this.logger.error('Unexpected error on idle client', err);
            process.exit(-1);
        });
    }
    /**
     * Ejecuta una consulta directa usando el Pool
     */
    async query(text, params) {
        const start = Date.now();
        const res = await this.pool.query(text, params);
        const duration = Date.now() - start;
        this.logger.debug(`Executed query: { text: ${text}, time: ${duration}ms, rows: ${res.rowCount} }`);
        return res;
    }
    /**
     * Obtiene un cliente dedicado del Pool
     * Ideal para transacciones múltiples
     */
    async getClient() {
        return await this.pool.connect();
    }
    /**
     * Envuelve una función dentro de un bloque Transaccional BEGIN / COMMIT
     * Si la función tira error, hace ROLLBACK automáticamente.
     */
    async withTransaction(callback) {
        const client = await this.getClient();
        try {
            await client.query('BEGIN');
            const result = await callback(client);
            await client.query('COMMIT');
            return result;
        }
        catch (e) {
            this.logger.error('Transaction rollback due to error', e.stack);
            await client.query('ROLLBACK');
            throw e;
        }
        finally {
            client.release();
        }
    }
};
exports.DatabaseService = DatabaseService;
exports.DatabaseService = DatabaseService = DatabaseService_1 = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, common_1.Inject)('PG_CONNECTION')),
    __metadata("design:paramtypes", [pg_1.Pool])
], DatabaseService);
