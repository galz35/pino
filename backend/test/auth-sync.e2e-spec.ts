import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import {
  FastifyAdapter,
  NestFastifyApplication,
} from '@nestjs/platform-fastify';
import request from 'supertest';
import { AppModule } from './../src/app.module';

describe('Auth & Sync Flow (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication<NestFastifyApplication>(
      new FastifyAdapter(),
    );
    
    // Crucial: replicate main.ts logic
    app.setGlobalPrefix('api');
    app.useGlobalPipes(new ValidationPipe({
      whitelist: true,
      transform: true,
    }));

    await app.init();
    await app.getHttpAdapter().getInstance().ready();
  });

  afterAll(async () => {
    await app.close();
  });

  const testUser = {
    email: `test_pino_${Date.now()}@example.com`,
    password: 'password123',
    name: 'PDA Test User',
    role: 'preventa'
  };

  let jwtToken: string;

  describe('Authentication', () => {
    it('/api/auth/register (POST) - Success', () => {
      return request(app.getHttpServer())
        .post('/api/auth/register')
        .send(testUser)
        .expect(201)
        .then(res => {
          expect(res.body.user.email).toBe(testUser.email);
        });
    });

    it('/api/auth/login (POST) - Success & Get Token', () => {
      return request(app.getHttpServer())
        .post('/api/auth/login')
        .send({
          email: testUser.email,
          password: testUser.password
        })
        .expect(201)
        .then(res => {
          expect(res.body.access_token).toBeDefined();
          jwtToken = res.body.access_token;
        });
    });

    it('/api/auth/me (GET) - Protected Route', () => {
      return request(app.getHttpServer())
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${jwtToken}`)
        .expect(200)
        .then(res => {
          expect(res.body.email).toBe(testUser.email);
        });
    });
  });

  describe('Core Data Accessibility', () => {
    it('/api/products (GET) - List products for offline sync', () => {
      return request(app.getHttpServer())
        .get('/api/products')
        .set('Authorization', `Bearer ${jwtToken}`)
        .expect(200)
        .then(res => {
          expect(Array.isArray(res.body)).toBe(true);
        });
    });

    it('/api/clients (GET) - List clients for offline sync', () => {
      return request(app.getHttpServer())
        .get('/api/clients')
        .set('Authorization', `Bearer ${jwtToken}`)
        .expect(200);
    });
  });
});
