import { IsString, IsEmail, IsNotEmpty, IsNumber, IsOptional, Min, IsArray } from 'class-validator';

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
}
