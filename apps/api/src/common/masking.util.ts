export function maskPhone(phone: string): string {
    if (phone.length <= 4) return '****';
    return '*'.repeat(phone.length - 4) + phone.slice(-4);
}

export function maskEmail(email: string): string {
    const [local, domain] = email.split('@');
    if (!domain) return '****';
    if (local.length <= 2) return `${local[0] || '*'}***@${domain}`;
    const visible = local.slice(0, 2);
    return `${visible}${'*'.repeat(local.length - 2)}@${domain}`;
}