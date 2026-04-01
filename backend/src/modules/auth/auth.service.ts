import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly db: DatabaseService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: {
    email: string;
    password: string;
    name: string;
    role: string;
    storeIds?: string[];
  }) {
    // Usamos el bloque transaccional del módulo pg puro
    return await this.db.withTransaction(async (client) => {
      // 1. Verificar si existe
      const existing = await client.query(
        'SELECT id FROM users WHERE email = $1',
        [dto.email],
      );
      if ((existing.rowCount ?? 0) > 0) throw new ConflictException('Email ya registrado');

      // 2. Hash e Insertar usuario
      const passwordHash = await bcrypt.hash(dto.password, 10);
      const resUser = await client.query(
        `INSERT INTO users (email, password_hash, name, role) 
         VALUES ($1, $2, $3, $4) RETURNING *`,
        [dto.email, passwordHash, dto.name, dto.role],
      );
      const savedUser = resUser.rows[0];

      // 3. Insertar tiendas asignadas
      if (dto.storeIds?.length) {
        for (const storeId of dto.storeIds) {
          await client.query(
            'INSERT INTO user_stores (user_id, store_id) VALUES ($1, $2)',
            [savedUser.id, storeId],
          );
        }
      }

      savedUser.userStores = dto.storeIds?.map(storeId => ({ storeId })) || [];
      return this.generateTokens(client, savedUser);
    });
  }

  async login(email: string, password: string) {
    const resUser = await this.db.query(
      'SELECT * FROM users WHERE email = $1 AND is_active = true',
      [email],
    );
    if ((resUser.rowCount ?? 0) === 0) throw new UnauthorizedException('Credenciales inválidas');

    const user = resUser.rows[0];

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) throw new UnauthorizedException('Credenciales inválidas');

    // Obtener sus tiendas
    const resStores = await this.db.query(
      'SELECT store_id FROM user_stores WHERE user_id = $1',
      [user.id]
    );
    user.userStores = resStores.rows.map(r => ({ storeId: r.store_id }));

    // Reutilizamos el pool principal para generar tokens
    const client = await this.db.getClient();
    try {
      return await this.generateTokens(client, user);
    } finally {
      client.release();
    }
  }

  async refreshToken(userId: string) {
    const resUser = await this.db.query(
      'SELECT * FROM users WHERE id = $1 AND is_active = true',
      [userId],
    );
    if (resUser.rowCount === 0) throw new UnauthorizedException('Usuario no encontrado');
    
    const user = resUser.rows[0];
    const resStores = await this.db.query(
      'SELECT store_id FROM user_stores WHERE user_id = $1',
      [user.id]
    );
    user.userStores = resStores.rows.map(r => ({ storeId: r.store_id }));

    const client = await this.db.getClient();
    try {
      return await this.generateTokens(client, user);
    } finally {
      client.release();
    }
  }

  async getProfile(userId: string) {
    const resUser = await this.db.query('SELECT * FROM users WHERE id = $1', [userId]);
    if (resUser.rowCount === 0) throw new UnauthorizedException('Usuario no encontrado');

    const user = resUser.rows[0];
    const resStores = await this.db.query(
      'SELECT store_id FROM user_stores WHERE user_id = $1',
      [user.id]
    );

    const { password_hash, refresh_token, ...profile } = user;
    return {
      ...profile,
      storeIds: resStores.rows.map(r => r.store_id) || [],
    };
  }

  private async generateTokens(client: any, user: any) {
    const storeIds = user.userStores?.map((us: any) => us.storeId) || [];
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      storeIds,
    };

    const accessToken = this.jwtService.sign(payload);
    const refreshTokenValue = this.jwtService.sign(payload, { expiresIn: '7d' });

    // Store refresh token en la BD
    await client.query(
      'UPDATE users SET refresh_token = $1 WHERE id = $2',
      [refreshTokenValue, user.id]
    );

    return {
      accessToken,
      access_token: accessToken,
      refreshToken: refreshTokenValue,
      refresh_token: refreshTokenValue,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        storeIds,
      },
    };
  }
}
