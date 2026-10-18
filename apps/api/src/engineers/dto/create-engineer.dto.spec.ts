import 'reflect-metadata';
import { validate } from 'class-validator';
import { plainToInstance } from 'class-transformer';
import { ValidationPipe } from '@nestjs/common';
import { CreateEngineerDto } from './create-engineer.dto';

describe('CreateEngineerDto Contract & Validation', () => {
    const pipe = new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
    });

    const baseValidPayload = {
        fullName: 'Ramesh Kumar',
        phone: '+919876543210',
        districtId: '123e4567-e89b-12d3-a456-426614174000',
    };

    async function transformAndValidate(payload: Record<string, any>) {
        return pipe.transform(payload, { type: 'body', metatype: CreateEngineerDto });
    }

    describe('Aadhaar Document Contract & Validation (Whitelist & ForbidNonWhitelisted)', () => {
        it('accepts valid S3 key in aadhaarCardUrl without rejection by forbidNonWhitelisted', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
                aadhaarCardUrl: 'android/sub-members/1729240000000-aadhaar.pdf',
            });
            expect(result.aadhaarCardUrl).toBe('android/sub-members/1729240000000-aadhaar.pdf');
        });

        it('accepts full S3 URL in aadhaarCardUrl', async () => {
            const s3Url = 'https://taspu-membership-documents-prod.s3.ap-south-1.amazonaws.com/android/sub-members/1729240000000-aadhaar.jpg';
            const result = await transformAndValidate({
                ...baseValidPayload,
                aadhaarCardUrl: s3Url,
            });
            expect(result.aadhaarCardUrl).toBe(s3Url);
        });

        it('allows aadhaarCardUrl to be completely omitted (optional)', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
            });
            expect(result.aadhaarCardUrl).toBeUndefined();
        });

        it('allows aadhaarCardUrl to be null', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
                aadhaarCardUrl: null,
            });
            expect(result.aadhaarCardUrl).toBeNull();
        });

        it('rejects non-string aadhaarCardUrl with HTTP 400', async () => {
            await expect(transformAndValidate({
                ...baseValidPayload,
                aadhaarCardUrl: 12345,
            })).rejects.toMatchObject({
                response: {
                    statusCode: 400,
                    message: expect.arrayContaining([expect.stringContaining('aadhaarCardUrl must be a string')]),
                },
            });
        });

        it('rejects unwhitelisted properties with forbidNonWhitelisted HTTP 400', async () => {
            await expect(transformAndValidate({
                ...baseValidPayload,
                unrecognizedProperty: 'invalid_value',
            })).rejects.toMatchObject({
                response: {
                    statusCode: 400,
                    message: expect.arrayContaining([expect.stringContaining('property unrecognizedProperty should not exist')]),
                },
            });
        });
    });

    describe('Valid Salary Values', () => {
        it('accepts and preserves a valid integer salary (e.g. 25000)', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
                salary: 25000,
            });
            expect(result.salary).toBe(25000);
        });

        it('accepts and preserves a valid decimal salary (e.g. 25000.50)', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
                salary: 25000.50,
            });
            expect(result.salary).toBe(25000.5);
        });

        it('accepts salary of 0', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
                salary: 0,
            });
            expect(result.salary).toBe(0);
        });
    });

    describe('Optional & Blank Salary Values', () => {
        it('allows salary to be omitted completely', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
            });
            expect(result.salary).toBeUndefined();
        });

        it('allows salary to be explicit null without error', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
                salary: null,
            });
            expect(result.salary).toBeNull();
        });

        it('transforms empty string salary "" to null without silently becoming 0', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
                salary: '',
            });
            expect(result.salary).toBeNull();
        });
    });

    describe('Formatted Salary Normalization', () => {
        it('normalizes string integer salary "25000" to number 25000', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
                salary: '25000',
            });
            expect(result.salary).toBe(25000);
        });

        it('normalizes comma-separated salary "25,000" to numeric 25000', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
                salary: '25,000',
            });
            expect(result.salary).toBe(25000);
        });

        it('normalizes currency prefixed salary "₹25000" to numeric 25000', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
                salary: '₹25000',
            });
            expect(result.salary).toBe(25000);
        });

        it('normalizes combined "₹ 25,000.50" to numeric 25000.5', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
                salary: '₹ 25,000.50',
            });
            expect(result.salary).toBe(25000.5);
        });

        it('normalizes "Rs. 50,000" to numeric 50000', async () => {
            const result = await transformAndValidate({
                ...baseValidPayload,
                salary: 'Rs. 50,000',
            });
            expect(result.salary).toBe(50000);
        });
    });

    describe('Invalid Salary Values Rejected with HTTP 400', () => {
        it('rejects negative salary numbers with min constraint error', async () => {
            await expect(transformAndValidate({
                ...baseValidPayload,
                salary: -500,
            })).rejects.toMatchObject({
                response: {
                    statusCode: 400,
                    message: expect.arrayContaining([expect.stringContaining('salary must not be less than 0')]),
                },
            });
        });

        it('rejects negative salary strings with min constraint error', async () => {
            await expect(transformAndValidate({
                ...baseValidPayload,
                salary: '-500',
            })).rejects.toMatchObject({
                response: {
                    statusCode: 400,
                    message: expect.arrayContaining([expect.stringContaining('salary must not be less than 0')]),
                },
            });
        });

        it('rejects non-numeric text "abc" without converting to zero', async () => {
            await expect(transformAndValidate({
                ...baseValidPayload,
                salary: 'abc',
            })).rejects.toMatchObject({
                response: {
                    statusCode: 400,
                    message: expect.arrayContaining([expect.stringContaining('salary must be a number')]),
                },
            });
        });
    });
});
