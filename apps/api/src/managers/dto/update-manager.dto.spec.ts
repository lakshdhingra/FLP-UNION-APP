import { validate } from 'class-validator';
import { plainToInstance } from 'class-transformer';
import { UpdateManagerDto } from './update-manager.dto';
import { extractS3Key } from '../../common/s3.util';

describe('Manager Profile Photo Contract Verification', () => {
    describe('extractS3Key', () => {
        it('extracts key from virtual-hosted S3 URL', () => {
            const url = 'https://taspu-membership-documents-prod.s3.ap-south-1.amazonaws.com/android/sub-members/1729210000-xyz.jpg';
            expect(extractS3Key(url)).toBe('android/sub-members/1729210000-xyz.jpg');
        });

        it('extracts key from path-style S3 URL', () => {
            const url = 'https://s3.ap-south-1.amazonaws.com/taspu-membership-documents-prod/android/managers/1729210000-xyz.jpg';
            expect(extractS3Key(url)).toBe('android/managers/1729210000-xyz.jpg');
        });

        it('preserves clean S3 keys unchanged', () => {
            const key = 'android/sub-members/1729210000-xyz.jpg';
            expect(extractS3Key(key)).toBe('android/sub-members/1729210000-xyz.jpg');
        });

        it('returns null for null or empty values', () => {
            expect(extractS3Key(null)).toBeNull();
            expect(extractS3Key('')).toBeNull();
            expect(extractS3Key(undefined)).toBeNull();
        });
    });

    describe('UpdateManagerDto Validation', () => {
        async function validateDto(payload: Record<string, any>) {
            const instance = plainToInstance<UpdateManagerDto, Record<string, any>>(UpdateManagerDto, payload);
            const errors = await validate(instance);
            return { instance, errors };
        }

        it('accepts canonical S3 URLs (satisfying strict @IsUrl backends)', async () => {
            const { errors } = await validateDto({
                profilePhotoUrl: 'https://taspu-membership-documents-prod.s3.ap-south-1.amazonaws.com/android/sub-members/1729210000-xyz.jpg',
            });
            expect(errors).toHaveLength(0);
        });

        it('accepts raw S3 object keys (sub-members and managers folders)', async () => {
            const { errors: err1 } = await validateDto({
                profilePhotoUrl: 'android/sub-members/1729210000-xyz.jpg',
            });
            expect(err1).toHaveLength(0);

            const { errors: err2 } = await validateDto({
                profilePhotoUrl: 'android/managers/1729210000-xyz.jpg',
            });
            expect(err2).toHaveLength(0);
        });

        it('transforms empty string to null and allows photo removal', async () => {
            const { instance, errors } = await validateDto({
                profilePhotoUrl: '',
            });
            expect(errors).toHaveLength(0);
            expect(instance.profilePhotoUrl).toBeNull();
        });

        it('accepts explicit null for photo removal', async () => {
            const { instance, errors } = await validateDto({
                profilePhotoUrl: null,
            });
            expect(errors).toHaveLength(0);
            expect(instance.profilePhotoUrl).toBeNull();
        });

        it('rejects malformed URLs or invalid keys', async () => {
            const { errors } = await validateDto({
                profilePhotoUrl: 'not a valid url or key!!',
            });
            expect(errors.length).toBeGreaterThan(0);
        });

        it('rejects path traversal attempts', async () => {
            const { errors } = await validateDto({
                profilePhotoUrl: 'android/sub-members/../../etc/passwd',
            });
            expect(errors.length).toBeGreaterThan(0);
        });
    });
});
