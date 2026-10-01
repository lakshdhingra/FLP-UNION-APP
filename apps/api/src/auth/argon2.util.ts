import * as argon2 from 'argon2';

const MEMORY_COST = Number(process.env.ARGON2_MEMORY_COST ?? 19456);
const TIME_COST = Number(process.env.ARGON2_TIME_COST ?? 2);
const PARALLELISM = Number(process.env.ARGON2_PARALLELISM ?? 1);

export async function hashPassword(plainPassword: string): Promise<string> {
    return argon2.hash(plainPassword, {
        type: argon2.argon2id,
        memoryCost: MEMORY_COST,
        timeCost: TIME_COST,
        parallelism: PARALLELISM,
    });
}

export async function verifyPassword(
    hash: string,
    plainPassword: string,
): Promise<boolean> {
    return argon2.verify(hash, plainPassword);
}