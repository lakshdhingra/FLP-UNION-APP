import {
    IsEmail,
    IsNotEmpty,
    IsString,
    IsUUID,
    Matches,
    MinLength,
} from 'class-validator';

export class RegisterManagerDto {
    @IsString()
    @IsNotEmpty()
    fullName!: string;

    // Basic international-friendly mobile format: optional +, 7-15 digits.
    @Matches(/^\+?[0-9]{7,15}$/, {
        message: 'mobile must be a valid phone number',
    })
    mobile!: string;

    @IsEmail()
    email!: string;

    @IsUUID()
    stateId!: string;

    @IsUUID()
    districtId!: string;

    // At least 8 chars, at least one letter and one number.
    @MinLength(8)
    @Matches(/(?=.*[A-Za-z])(?=.*\d)/, {
        message: 'password must contain at least one letter and one number',
    })
    password!: string;

    @IsString()
    @IsNotEmpty()
    confirmPassword!: string;
}