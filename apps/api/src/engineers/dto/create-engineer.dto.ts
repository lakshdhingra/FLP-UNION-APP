import {
    IsString, IsNotEmpty, IsOptional, IsEmail,
    IsArray, IsUUID, Matches,
} from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { IsNumber, Min, Max } from 'class-validator';

export class CreateEngineerDto {
    @IsString() @IsNotEmpty()
    fullName!: string;

    @Matches(/^\+?[0-9]{7,15}$/, { message: 'phone must be a valid number' })
    phone!: string;

    @IsOptional() @IsEmail()
    email?: string;

    @IsOptional() @IsString()
    profilePhotoUrl?: string;

    @IsOptional() @IsString()
    aadhaarCardUrl?: string;

    @IsOptional() @IsString()
    address?: string;

    @IsUUID()
    districtId!: string;

    @IsOptional() @IsArray() @IsString({ each: true })
    skills?: string[];

    @IsOptional() @IsNumber() @Min(0) @Max(60) @Type(() => Number)
    experienceYears?: number;

    @IsOptional() @IsString()
    designation?: string;

    @IsOptional() @IsString()
    govIdType?: string;

    @IsOptional() @IsString()
    govIdNumber?: string;

    @IsOptional()
    @Transform(({ value }) => {
        if (value === '' || value === null || value === undefined) return null;
        if (typeof value === 'string') {
            const clean = value.replace(/[₹\u20B9\s,]|Rs\.?|INR/gi, '').trim();
            if (clean === '') return null;
            const parsed = Number(clean);
            return isNaN(parsed) ? value : parsed;
        }
        return value;
    })
    @IsNumber()
    @Min(0)
    salary?: number;

    @IsOptional() @IsString()
    privateNotes?: string;
}
