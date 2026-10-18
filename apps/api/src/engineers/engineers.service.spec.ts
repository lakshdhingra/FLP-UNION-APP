import { Test, TestingModule } from '@nestjs/testing';
import { EngineersService } from './engineers.service';
import { PrismaService } from '../prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { S3Service } from '../s3/s3.service';
import { ForbiddenException, NotFoundException } from '@nestjs/common';

describe('EngineersService - Aadhaar Document Flow & Confidentiality', () => {
    let service: EngineersService;
    let prisma: any;
    let audit: any;
    let s3Service: any;

    const mockManager = {
        id: 'manager-uuid-1',
        userId: 'user-uuid-1',
        fullName: 'Proprietor One',
        stateId: 'state-telangana-uuid',
        profilePhotoUrl: 'android/managers/profile-1.jpg',
    };

    const mockOtherManager = {
        id: 'manager-uuid-2',
        userId: 'user-uuid-2',
        fullName: 'Proprietor Two',
        stateId: 'state-telangana-uuid', // same state, different owner
        profilePhotoUrl: 'android/managers/profile-2.jpg',
    };

    const mockDistrict = {
        id: 'dist-hyderabad-uuid',
        name: 'Hyderabad',
        stateId: 'state-telangana-uuid',
    };

    beforeEach(async () => {
        prisma = {
            managerProfile: {
                findUnique: jest.fn(),
            },
            district: {
                findUnique: jest.fn().mockResolvedValue(mockDistrict),
            },
            engineer: {
                create: jest.fn(),
                update: jest.fn(),
                findUnique: jest.fn(),
                findFirst: jest.fn(),
            },
        };

        audit = {
            log: jest.fn(),
        };

        s3Service = {
            getPresignedUploadUrl: jest.fn(),
            getPresignedDownloadUrl: jest.fn().mockResolvedValue('https://s3-signed-download-url.amazonaws.com/test'),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                EngineersService,
                { provide: PrismaService, useValue: prisma },
                { provide: AuditService, useValue: audit },
                { provide: S3Service, useValue: s3Service },
            ],
        }).compile();

        service = module.get<EngineersService>(EngineersService);
    });

    describe('Scenario 1: Create an engineer without an Aadhaar document', () => {
        it('successfully creates engineer with aadhaarCardUrl as null when omitted', async () => {
            prisma.managerProfile.findUnique.mockResolvedValue(mockManager);

            const createdRecord = {
                id: 'eng-uuid-1',
                fullName: 'Kiran Reddy',
                phone: '+919876543210',
                districtId: mockDistrict.id,
                stateId: mockManager.stateId,
                managerId: mockManager.id,
                aadhaarCardUrl: null,
                profilePhotoUrl: null,
                salary: 30000,
            };
            prisma.engineer.create.mockResolvedValue(createdRecord);

            const result = await service.create(mockManager.userId, {
                fullName: 'Kiran Reddy',
                phone: '+919876543210',
                districtId: mockDistrict.id,
                salary: 30000,
            });

            expect(prisma.engineer.create).toHaveBeenCalledWith({
                data: expect.objectContaining({
                    fullName: 'Kiran Reddy',
                    phone: '+919876543210',
                    aadhaarCardUrl: null,
                    profilePhotoUrl: null,
                    managerId: mockManager.id,
                    stateId: mockManager.stateId,
                }),
                include: {
                    district: { select: { name: true } },
                    state: { select: { name: true } },
                },
            });
            expect((result as any).aadhaarCardUrl).toBeNull();
            expect(result.id).toBe('eng-uuid-1');
        });
    });

    describe('Scenario 2: Create an engineer with a valid uploaded Aadhaar document', () => {
        it('persists clean S3 key when valid aadhaar S3 key is passed', async () => {
            prisma.managerProfile.findUnique.mockResolvedValue(mockManager);

            const aadhaarKey = 'android/sub-members/1729240000000-aadhaar.pdf';
            const createdRecord = {
                id: 'eng-uuid-2',
                fullName: 'Suresh Kumar',
                phone: '+919876543211',
                districtId: mockDistrict.id,
                stateId: mockManager.stateId,
                managerId: mockManager.id,
                aadhaarCardUrl: aadhaarKey,
                salary: 35000,
            };
            prisma.engineer.create.mockResolvedValue(createdRecord);

            const result = await service.create(mockManager.userId, {
                fullName: 'Suresh Kumar',
                phone: '+919876543211',
                districtId: mockDistrict.id,
                aadhaarCardUrl: aadhaarKey,
                salary: 35000,
            });

            expect(prisma.engineer.create).toHaveBeenCalledWith({
                data: expect.objectContaining({
                    aadhaarCardUrl: aadhaarKey,
                    managerId: mockManager.id,
                }),
                include: {
                    district: { select: { name: true } },
                    state: { select: { name: true } },
                },
            });
            expect((result as any).aadhaarCardUrl).toBe(aadhaarKey);
        });

        it('extracts S3 key if full S3 URL is provided in aadhaarCardUrl', async () => {
            prisma.managerProfile.findUnique.mockResolvedValue(mockManager);

            const fullUrl = 'https://taspu-membership-documents-prod.s3.ap-south-1.amazonaws.com/android/sub-members/1729240000000-aadhaar.jpg';
            const cleanKey = 'android/sub-members/1729240000000-aadhaar.jpg';

            prisma.engineer.create.mockResolvedValue({
                id: 'eng-uuid-3',
                fullName: 'Anil Rao',
                phone: '+919876543212',
                districtId: mockDistrict.id,
                aadhaarCardUrl: cleanKey,
            });

            const result = await service.create(mockManager.userId, {
                fullName: 'Anil Rao',
                phone: '+919876543212',
                districtId: mockDistrict.id,
                aadhaarCardUrl: fullUrl,
            });

            expect(prisma.engineer.create).toHaveBeenCalledWith({
                data: expect.objectContaining({
                    aadhaarCardUrl: cleanKey,
                }),
                include: expect.any(Object),
            });
            expect((result as any).aadhaarCardUrl).toBe(cleanKey);
        });
    });

    describe('Scenario 3: Persistence and retrieval for owning manager', () => {
        it('returns full record with aadhaarCardUrl and isOwned: true for owning manager', async () => {
            prisma.managerProfile.findUnique.mockResolvedValue(mockManager);

            const engineer = {
                id: 'eng-uuid-2',
                fullName: 'Suresh Kumar',
                phone: '+919876543211',
                email: 'suresh@example.com',
                aadhaarCardUrl: 'android/sub-members/1729240000000-aadhaar.pdf',
                stateId: mockManager.stateId,
                managerId: mockManager.id,
                salary: 35000,
                privateNotes: 'Top certified technician',
            };
            prisma.engineer.findUnique.mockResolvedValue(engineer);

            const result = await service.findOne(mockManager.userId, 'eng-uuid-2');
            expect(result.isOwned).toBe(true);
            expect((result as any).aadhaarCardUrl).toBe('android/sub-members/1729240000000-aadhaar.pdf');
            expect((result as any).salary).toBe(35000);
            expect((result as any).privateNotes).toBe('Top certified technician');
        });

        it('generates signed download URL when owning manager requests Aadhaar document', async () => {
            prisma.managerProfile.findUnique.mockResolvedValue(mockManager);

            const key = 'android/sub-members/1729240000000-aadhaar.pdf';
            prisma.engineer.findFirst.mockResolvedValue({
                id: 'eng-uuid-2',
                aadhaarCardUrl: key,
                profilePhotoUrl: null,
                managerId: mockManager.id,
                stateId: mockManager.stateId,
            });

            const res = await service.getDocumentUrl(mockManager.userId, key);
            expect(res.signedUrl).toBe('https://s3-signed-download-url.amazonaws.com/test');
            expect(s3Service.getPresignedDownloadUrl).toHaveBeenCalledWith(key, 3600);
        });
    });

    describe('Scenario 4: Confidential document protection and access control', () => {
        const confidentialKey = 'android/sub-members/1729240000000-aadhaar.pdf';
        const ownedEngineer = {
            id: 'eng-uuid-2',
            fullName: 'Suresh Kumar',
            phone: '9876543211',
            email: 'suresh@example.com',
            aadhaarCardUrl: confidentialKey,
            profilePhotoUrl: 'android/sub-members/profile.jpg',
            stateId: mockManager.stateId,
            managerId: mockManager.id, // belongs to mockManager
            salary: 35000,
            privateNotes: 'Top technician',
        };

        it('forbids other manager in same state from accessing the Aadhaar document URL', async () => {
            prisma.managerProfile.findUnique.mockResolvedValue(mockOtherManager);
            prisma.engineer.findFirst.mockResolvedValue(ownedEngineer);

            await expect(
                service.getDocumentUrl(mockOtherManager.userId, confidentialKey)
            ).rejects.toThrow(new ForbiddenException('You do not have permission to access this Aadhaar document'));
        });

        it('masks and completely omits aadhaarCardUrl when other manager views the engineer', async () => {
            prisma.managerProfile.findUnique.mockResolvedValue(mockOtherManager);
            prisma.engineer.findUnique.mockResolvedValue(ownedEngineer);

            const result = await service.findOne(mockOtherManager.userId, 'eng-uuid-2');
            expect(result.isOwned).toBe(false);
            expect((result as any).aadhaarCardUrl).toBeUndefined();
            expect((result as any).salary).toBeUndefined();
            expect((result as any).privateNotes).toBeUndefined();
            expect(result.fullName).toBe('Suresh Kumar');
        });
    });
});
