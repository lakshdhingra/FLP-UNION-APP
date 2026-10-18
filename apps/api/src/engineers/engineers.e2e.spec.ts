import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
const request = require('supertest');
import { EngineersController } from './engineers.controller';
import { EngineersService } from './engineers.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';

describe('Engineers HTTP E2E Pipeline (ValidationPipe forbidNonWhitelisted)', () => {
    let app: INestApplication;
    let mockService: any;

    const mockManagerUser = {
        userId: 'user-manager-uuid-1',
        role: 'MANAGER',
    };

    beforeAll(async () => {
        mockService = {
            create: jest.fn().mockImplementation((userId, dto) => {
                return Promise.resolve({
                    id: 'eng-created-uuid-123',
                    fullName: dto.fullName,
                    phone: dto.phone,
                    districtId: dto.districtId,
                    aadhaarCardUrl: dto.aadhaarCardUrl ?? null,
                    profilePhotoUrl: dto.profilePhotoUrl ?? null,
                    salary: dto.salary ?? null,
                    managerId: 'mgr-1',
                });
            }),
            getDocumentUrl: jest.fn().mockResolvedValue({
                signedUrl: 'https://s3.ap-south-1.amazonaws.com/test-signed-url',
            }),
        };

        const moduleRef: TestingModule = await Test.createTestingModule({
            controllers: [EngineersController],
            providers: [
                { provide: EngineersService, useValue: mockService },
            ],
        })
            .overrideGuard(JwtAuthGuard)
            .useValue({
                canActivate: (context: any) => {
                    const req = context.switchToHttp().getRequest();
                    req.user = mockManagerUser;
                    return true;
                },
            })
            .overrideGuard(RolesGuard)
            .useValue({ canActivate: () => true })
            .compile();

        app = moduleRef.createNestApplication();

        // Exact validation pipe configuration as apps/api/src/main.ts
        app.useGlobalPipes(
            new ValidationPipe({
                whitelist: true,
                forbidNonWhitelisted: true,
                transform: true,
            }),
        );

        await app.init();
    });

    afterAll(async () => {
        await app.close();
    });

    it('Scenario A: Submitting engineer WITH valid uploaded aadhaarCardUrl succeeds with HTTP 201', async () => {
        const payload = {
            fullName: 'Ramesh Patel',
            phone: '+919876543210',
            districtId: '123e4567-e89b-12d3-a456-426614174000',
            aadhaarCardUrl: 'android/sub-members/1792314363803-aadhaar-doc.pdf',
            salary: '₹ 35,000',
        };

        const response = await request(app.getHttpServer())
            .post('/manager/engineers')
            .send(payload)
            .expect(201);

        console.log('ACTUAL HTTP 201 RESPONSE WITH AADHAAR:', JSON.stringify(response.body, null, 2));

        expect(response.body).toMatchObject({
            id: 'eng-created-uuid-123',
            fullName: 'Ramesh Patel',
            phone: '+919876543210',
            aadhaarCardUrl: 'android/sub-members/1792314363803-aadhaar-doc.pdf',
            salary: 35000,
        });
        expect(response.body.message).toBeUndefined();
    });

    it('Scenario B: Submitting engineer WITHOUT aadhaarCardUrl succeeds with HTTP 201', async () => {
        const payload = {
            fullName: 'Suresh Kumar',
            phone: '+919876543211',
            districtId: '123e4567-e89b-12d3-a456-426614174000',
        };

        const response = await request(app.getHttpServer())
            .post('/manager/engineers')
            .send(payload)
            .expect(201);

        console.log('ACTUAL HTTP 201 RESPONSE WITHOUT AADHAAR:', JSON.stringify(response.body, null, 2));

        expect(response.body).toMatchObject({
            id: 'eng-created-uuid-123',
            fullName: 'Suresh Kumar',
            aadhaarCardUrl: null,
        });
    });

    it('Scenario C: Unknown unwhitelisted property is rejected with HTTP 400', async () => {
        const payload = {
            fullName: 'Invalid Engineer',
            phone: '+919876543212',
            districtId: '123e4567-e89b-12d3-a456-426614174000',
            unrecognizedField: 'malicious_or_unknown',
        };

        const response = await request(app.getHttpServer())
            .post('/manager/engineers')
            .send(payload)
            .expect(400);

        console.log('ACTUAL HTTP 400 RESPONSE FOR UNWHITELISTED FIELD:', JSON.stringify(response.body, null, 2));

        expect(response.body.message).toContain('property unrecognizedField should not exist');
    });
});
