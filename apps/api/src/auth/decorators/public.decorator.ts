import { SetMetadata } from '@nestjs/common';

/** Mark any route handler as publicly accessible (no JWT required). */
export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
