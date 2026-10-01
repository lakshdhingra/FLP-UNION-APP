export const Colors = {
  // Backgrounds
  background: '#09090B',
  surface: '#111113',
  card: '#18181B',
  cardHover: '#1F1F23',
  border: '#27272A',

  // Text
  textPrimary: '#FAFAFA',
  textSecondary: '#A1A1AA',
  textMuted: '#71717A',

  // Brand / Accent
  accent: '#2563EB',
  accentHover: '#1D4ED8',
  accentSubtle: '#1E3A8A',

  // Status
  success: '#16A34A',
  successBg: '#052E16',
  warning: '#F59E0B',
  warningBg: '#451A03',
  danger: '#DC2626',
  dangerBg: '#450A0A',
  info: '#0EA5E9',

  // Overlays
  overlay: 'rgba(0,0,0,0.6)',
  cardPressed: '#0F0F11',
} as const;

export const Spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
} as const;

export const BorderRadius = {
  sm: 6,
  md: 10,
  lg: 14,
  xl: 20,
  full: 9999,
} as const;

export const FontSize = {
  xs: 11,
  sm: 13,
  md: 15,
  lg: 17,
  xl: 20,
  xxl: 24,
  xxxl: 30,
} as const;

export const FontWeight = {
  normal: '400' as const,
  medium: '500' as const,
  semibold: '600' as const,
  bold: '700' as const,
} as const;

export const Shadow = {
  sm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.3,
    shadowRadius: 2,
    elevation: 2,
  },
  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 8,
    elevation: 6,
  },
} as const;
