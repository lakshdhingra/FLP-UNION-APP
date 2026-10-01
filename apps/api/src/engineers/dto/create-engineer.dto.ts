import {
    IsString, IsNotEmpty, IsOptional, IsEmail,
    IsArray, IsUUID, Matches,
} from 'class-validator';
import { Type } from 'class-transformer';
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

    @IsOptional() @IsNumber() @Min(0) @Type(() => Number)
    salary?: number;

    @IsOptional() @IsString()
    privateNotes?: string;
}
