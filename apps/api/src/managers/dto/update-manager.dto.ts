import {
    IsOptional,
    IsString,
    IsArray,
    Validate,
    ValidatorConstraint,
    ValidatorConstraintInterface,
    ValidationArguments,
    isURL,
} from 'class-validator';
import { Transform } from 'class-transformer';

@ValidatorConstraint({ name: 'isUrlOrS3Key', async: false })
export class IsUrlOrS3KeyConstraint implements ValidatorConstraintInterface {
    validate(value: any, _args?: ValidationArguments) {
        if (value === null || value === undefined) return true;
        if (typeof value !== 'string') return false;
        const trimmed = value.trim();
        if (!trimmed) return false;

        // If it starts with http:// or https://, validate as full URL
        if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
            return isURL(trimmed, { require_protocol: true });
        }

        // Otherwise validate as safe S3 object key (e.g. android/managers/..., android/sub-members/..., etc.)
        return /^[a-zA-Z0-9_\-\.\/]+$/.test(trimmed) && !trimmed.includes('..');
    }

    defaultMessage(_args?: ValidationArguments) {
        return 'profilePhotoUrl must be a valid URL address or S3 object key';
    }
}

export class UpdateManagerDto {
    @IsOptional()
    @IsString()
    fullName?: string;

    @IsOptional()
    @Transform(({ value }) => {
        if (value === '' || value === null) return null;
        return typeof value === 'string' ? value.trim() : value;
    })
    @Validate(IsUrlOrS3KeyConstraint)
    profilePhotoUrl?: string | null;

    @IsOptional()
    @Transform(({ value }) => {
        if (typeof value === 'string') {
            return value.split(',').map((s: string) => s.trim()).filter(Boolean);
        }
        if (Array.isArray(value)) {
            return value.map((s: any) => String(s).trim()).filter(Boolean);
        }
        return value;
    })
    @IsArray()
    @IsString({ each: true })
    brandsWorkedWith?: string[];
}
