export function extractS3Key(keyOrUrl?: string | null): string | null {
    if (!keyOrUrl) return null;
    const trimmed = keyOrUrl.trim();
    if (!trimmed) return null;
    try {
        if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
            const parsed = new URL(trimmed);
            let pathname = parsed.pathname;
            if (pathname.startsWith('/')) pathname = pathname.slice(1);
            if (pathname.startsWith('taspu-membership-documents-prod/')) {
                pathname = pathname.replace(/^taspu-membership-documents-prod\//, '');
            }
            return decodeURIComponent(pathname);
        }
    } catch {
        // Fallback
    }
    return trimmed;
}
