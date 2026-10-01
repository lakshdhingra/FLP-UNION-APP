import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsUUID } from 'class-validator';

export class CreateStateDto {
    @IsString() @IsNotEmpty()
    name!: string;
}

export class UpdateStateDto {
    @IsOptional() @IsString() @IsNotEmpty()
    name?: string;
    @IsOptional() @IsBoolean()
    isActive?: boolean;
}

export class CreateDistrictDto {
    @IsString() @IsNotEmpty()
    name!: string;
    @IsUUID()
    stateId!: string;
}

export class UpdateDistrictDto {
    @IsOptional() @IsString() @IsNotEmpty()
    name?: string;
    @IsOptional() @IsBoolean()
    isActive?: boolean;
}

export class AdminUpdateEngineerDto {
    @IsOptional() @IsString() @IsNotEmpty()
    fullName?: string;

    @IsOptional() @IsString()
    phone?: string;

    @IsOptional() @IsString()
    email?: string;

    @IsOptional() @IsString()
    profilePhotoUrl?: string;

    @IsOptional() @IsString()
    address?: string;

    @IsOptional() @IsUUID()
    stateId?: string;

    @IsOptional() @IsUUID()
    districtId?: string;

    @IsOptional() @IsUUID()
    managerId?: string;

    @IsOptional() @IsString()
    designation?: string;

    @IsOptional() @IsString()
    govIdType?: string;

    @IsOptional() @IsString()
    govIdNumber?: string;

    @IsOptional() @IsString()
    privateNotes?: string;

    @IsOptional() @IsBoolean()
    isActive?: boolean;
}
