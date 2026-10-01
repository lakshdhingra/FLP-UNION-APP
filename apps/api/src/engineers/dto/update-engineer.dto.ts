import { PartialType } from '@nestjs/mapped-types';
import { CreateEngineerDto } from './create-engineer.dto';
import { IsBoolean, IsOptional } from 'class-validator';

export class UpdateEngineerDto extends PartialType(CreateEngineerDto) {
    @IsOptional() @IsBoolean()
    isActive?: boolean;
}
