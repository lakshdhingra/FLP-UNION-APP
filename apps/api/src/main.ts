import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
    const app = await NestFactory.create(AppModule);

    app.use(helmet());
    const allowedOrigins = (process.env.CORS_ORIGINS ?? '').split(',').filter(Boolean);
    app.enableCors({
        origin: (origin, callback) => {
            if (!origin) return callback(null, true);
            if (/^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)) {
                return callback(null, true);
            }
            if (/^https?:\/\/([a-z0-9-]+\.)*tapsu\.in(:\d+)?$/.test(origin)) {
                return callback(null, true);
            }
            if (allowedOrigins.length === 0 || allowedOrigins.includes(origin)) {
                return callback(null, true);
            }
            callback(new Error('Not allowed by CORS'));
        },
        credentials: true,
    });

    app.useGlobalPipes(
        new ValidationPipe({
            whitelist: true,
            forbidNonWhitelisted: true,
            transform: true,
        }),
    );

    app.setGlobalPrefix('api');

    // Swagger / OpenAPI
    const config = new DocumentBuilder()
        .setTitle('TASPU API')
        .setDescription('Telangana Authorized Service Centre Proprietors Union - Management Platform API')
        .setVersion('1.0')
        .addBearerAuth()
        .build();
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);

    const port = process.env.PORT ?? 3000;
    await app.listen(port, '0.0.0.0');
    console.log(`TASPU API running on http://localhost:${port}/api`);
    console.log(`Swagger docs at http://localhost:${port}/api/docs`);
}
bootstrap();
