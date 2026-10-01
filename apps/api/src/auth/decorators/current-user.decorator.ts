import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface CurrentUserPayload {
    userId: string;
    role: 'ADMIN' | 'MANAGER';
}

// Usage in a controller: async myRoute(@CurrentUser() user: CurrentUserPayload)
export const CurrentUser = createParamDecorator(
    (_data: unknown, ctx: ExecutionContext): CurrentUserPayload => {
        const request = ctx.switchToHttp().getRequest();
        return request.user;
    },
);