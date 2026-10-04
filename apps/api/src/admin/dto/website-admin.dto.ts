import { IsString, IsNotEmpty, IsOptional, IsEnum, IsArray } from 'class-validator';

export class UpdateAppStatusDto {
  @IsString()
  status!: 'UNDER_REVIEW' | 'APPROVED' | 'REJECTED';

  @IsString()
  @IsOptional()
  adminNotes?: string;

  @IsString()
  @IsOptional()
  rejectionReason?: string;
}

export class SaveAppNotesDto {
  @IsString()
  notes!: string;
}

export class CreateManualMemberDto {
  @IsString() @IsNotEmpty() membershipId!: string;
  @IsString() @IsNotEmpty() fullName!: string;
  @IsString() @IsNotEmpty() serviceCenterName!: string;
  @IsArray() brandsWorkedWith!: string[];
  @IsString() gstNo!: string;
  @IsString() fullAddress!: string;
  @IsString() district!: string;
  @IsString() city!: string;
  @IsString() phone!: string;
  @IsString() email!: string;
}

export class UpdateMemberDto {
  @IsString() @IsNotEmpty() membershipId!: string;
  @IsString() @IsNotEmpty() fullName!: string;
  @IsString() @IsNotEmpty() serviceCenterName!: string;
  @IsArray() brandsWorkedWith!: string[];
  @IsString() gstNo!: string;
  @IsString() fullAddress!: string;
  @IsString() district!: string;
  @IsString() city!: string;
  @IsString() phone!: string;
  @IsString() email!: string;
}
