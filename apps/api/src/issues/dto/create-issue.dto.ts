import { IsString, IsNotEmpty, IsOptional, IsEnum } from 'class-validator';
import { IssueType } from '@prisma/client';

export class CreateIssueDto {
    @IsEnum(IssueType)
    type!: IssueType;

    @IsString() @IsNotEmpty()
    title!: string;

    @IsString() @IsNotEmpty()
    description!: string;

    @IsOptional() @IsString()
    attachmentUrl?: string;
}
