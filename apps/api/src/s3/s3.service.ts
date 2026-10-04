import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

@Injectable()
export class S3Service {
  private readonly logger = new Logger(S3Service.name);
  private s3Client: S3Client;
  private bucketName: string;

  constructor(private configService: ConfigService) {
    const region = this.configService.get<string>('AWS_REGION') || 'ap-south-1';
    this.bucketName = this.configService.get<string>('S3_BUCKET') || 'taspu-membership-documents-prod';

    // Default Credential Provider Chain uses EC2 IAM Role automatically
    this.s3Client = new S3Client({ region });
  }

  /**
   * Generates a short-lived presigned URL for uploading a document directly to AWS S3.
   */
  async getPresignedUploadUrl(
    folderPath: string,
    originalName: string,
    mimeType: string,
  ) {
    const allowedMimeTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
    const normalizedMime = (mimeType || '').toLowerCase().trim();

    if (!allowedMimeTypes.includes(normalizedMime)) {
      throw new BadRequestException(
        `Invalid file type '${mimeType}'. Allowed types: ${allowedMimeTypes.join(', ')}`,
      );
    }

    const lastDot = originalName.lastIndexOf('.');
    const ext = lastDot !== -1 ? originalName.slice(lastDot).toLowerCase() : '';
    const baseName = lastDot !== -1 ? originalName.slice(0, lastDot) : originalName;
    const safeBase = baseName.replace(/[^a-zA-Z0-9_\-]/g, '_');
    const safeFileName = `${safeBase}${ext}`;

    const uniqueId = `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
    const objectKey = `${folderPath}/${uniqueId}-${safeFileName}`;

    const command = new PutObjectCommand({
      Bucket: this.bucketName,
      Key: objectKey,
      ContentType: normalizedMime,
    });

    const signedUrl = await getSignedUrl(this.s3Client, command, { expiresIn: 900 });

    return {
      key: objectKey,
      signedUrl,
      expiresIn: 900,
      originalName,
      mimeType: normalizedMime,
    };
  }

  /**
   * Generates a short-lived presigned URL for viewing/downloading a private document from AWS S3.
   */
  async getPresignedDownloadUrl(key: string, expiresInSeconds: number = 3600): Promise<string> {
    if (!key) {
      throw new BadRequestException('S3 object key is required');
    }

    const command = new GetObjectCommand({
      Bucket: this.bucketName,
      Key: key,
    });

    return getSignedUrl(this.s3Client, command, { expiresIn: expiresInSeconds });
  }

  /**
   * Deletes an S3 object key.
   */
  async deleteObject(key: string): Promise<void> {
    try {
      const command = new DeleteObjectCommand({
        Bucket: this.bucketName,
        Key: key,
      });
      await this.s3Client.send(command);
    } catch (error) {
      this.logger.error(`Failed to delete S3 object: ${key}`, error);
    }
  }
}
