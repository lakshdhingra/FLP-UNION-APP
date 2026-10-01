import { IsOptional, IsString, IsUrl } from 'class-validator';

export class UpdateManagerDto {
    @IsOptional() @IsString()
    fullName?: string;

    @IsOptional()
    @IsString()
    @IsUrl()
    profilePhotoUrl?: string;
}
