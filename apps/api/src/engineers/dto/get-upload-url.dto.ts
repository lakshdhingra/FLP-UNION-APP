import { IsNotEmpty, IsString } from 'class-validator';

export class GetEngineerUploadUrlDto {
  @IsString() @IsNotEmpty()
  fileName!: string;

  @IsString() @IsNotEmpty()
  mimeType!: string;
}
