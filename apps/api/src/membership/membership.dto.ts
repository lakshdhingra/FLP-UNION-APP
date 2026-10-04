import { IsString, IsEmail, IsNotEmpty, IsNumber, IsOptional, Min, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class GetUploadUrlDto {
  @IsString() @IsNotEmpty() fileName!: string;
  @IsString() @IsNotEmpty() mimeType!: string;
  @IsString() @IsOptional() tempId?: string;
}

export class DocumentItemDto {
  @IsString() @IsNotEmpty() key!: string;
  @IsString() @IsNotEmpty() originalName!: string;
  @IsString() @IsOptional() mimeType?: string;
  @IsNumber() @IsOptional() size?: number;
}

export class CreateApplicationDto {
  @IsString() @IsNotEmpty() fullName!: string;
  @IsEmail() @IsNotEmpty() email!: string;
  @IsString() @IsNotEmpty() phone!: string;
  @IsString() @IsNotEmpty() serviceCenterName!: string;
  @IsString() @IsNotEmpty() designation!: string;
  @IsNumber() @Min(0) yearsExperience!: number;
  @IsArray() brandsWorkedWith!: string[];
  @IsString() gstNo!: string;
  @IsString() @IsNotEmpty() district!: string;
  @IsString() @IsNotEmpty() city!: string;
  @IsString() @IsNotEmpty() address!: string;
  @IsString() @IsNotEmpty() fullAddress!: string;
  @IsString() @IsOptional() reasonForJoining?: string;
  @IsString() @IsOptional() additionalInfo?: string;
  @IsArray() @IsOptional() @ValidateNested({ each: true }) @Type(() => DocumentItemDto) documents?: DocumentItemDto[];
}
