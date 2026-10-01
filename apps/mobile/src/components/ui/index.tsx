import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ViewStyle } from 'react-native';
import { Colors, BorderRadius, Spacing, FontSize, FontWeight } from '../../constants/theme';

// ─── Card ──────────────────────────────────────────────────────────────────
interface CardProps {
  children: React.ReactNode;
  style?: ViewStyle;
  onPress?: () => void;
  padding?: boolean;
}
export function Card({ children, style, onPress, padding = true }: CardProps) {
  if (onPress) {
    return (
      <TouchableOpacity
        activeOpacity={0.7}
        onPress={onPress}
        style={[styles.card, padding && styles.padding, style]}
      >
        {children}
      </TouchableOpacity>
    );
  }
  return <View style={[styles.card, padding && styles.padding, style]}>{children}</View>;
}

// ─── Badge ─────────────────────────────────────────────────────────────────
type BadgeVariant = 'success' | 'warning' | 'danger' | 'default' | 'info';
interface BadgeProps { label: string; variant?: BadgeVariant; }
export function Badge({ label, variant = 'default' }: BadgeProps) {
  return (
    <View style={[styles.badge, styles[`badge_${variant}`]]}>
      <Text style={[styles.badgeText, styles[`badgeText_${variant}`]]}>{label}</Text>
    </View>
  );
}

// ─── Avatar ────────────────────────────────────────────────────────────────
interface AvatarProps { name: string; size?: number; url?: string; }
export function Avatar({ name, size = 44 }: AvatarProps) {
  const initials = name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();
  return (
    <View style={[styles.avatar, { width: size, height: size, borderRadius: size / 2 }]}>
      <Text style={[styles.avatarText, { fontSize: size * 0.38 }]}>{initials}</Text>
    </View>
  );
}

// ─── ScreenHeader ──────────────────────────────────────────────────────────
interface ScreenHeaderProps { title: string; subtitle?: string; right?: React.ReactNode; }
export function ScreenHeader({ title, subtitle, right }: ScreenHeaderProps) {
  return (
    <View style={styles.header}>
      <View style={{ flex: 1 }}>
        <Text style={styles.headerTitle}>{title}</Text>
        {subtitle && <Text style={styles.headerSubtitle}>{subtitle}</Text>}
      </View>
      {right}
    </View>
  );
}

// ─── EmptyState ────────────────────────────────────────────────────────────
interface EmptyStateProps {
  title: string;
  description?: string;
  action?: { label: string; onPress: () => void };
  icon?: React.ReactNode;
}
export function EmptyState({ title, description, action, icon }: EmptyStateProps) {
  return (
    <View style={styles.emptyWrapper}>
      {icon && <View style={styles.emptyIcon}>{icon}</View>}
      <Text style={styles.emptyTitle}>{title}</Text>
      {description && <Text style={styles.emptyDesc}>{description}</Text>}
      {action && (
        <TouchableOpacity onPress={action.onPress} style={styles.emptyAction}>
          <Text style={styles.emptyActionText}>{action.label}</Text>
        </TouchableOpacity>
      )}
    </View>
  );
}

// ─── ErrorState ────────────────────────────────────────────────────────────
interface ErrorStateProps { message?: string; onRetry?: () => void; }
export function ErrorState({ message = 'Something went wrong.', onRetry }: ErrorStateProps) {
  return (
    <View style={styles.emptyWrapper}>
      <Text style={styles.errorTitle}>Unable to load</Text>
      <Text style={styles.emptyDesc}>{message}</Text>
      {onRetry && (
        <TouchableOpacity onPress={onRetry} style={styles.emptyAction}>
          <Text style={styles.emptyActionText}>Retry</Text>
        </TouchableOpacity>
      )}
    </View>
  );
}

// ─── Divider ───────────────────────────────────────────────────────────────
export function Divider({ style }: { style?: ViewStyle }) {
  return <View style={[styles.divider, style]} />;
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: Colors.card,
    borderRadius: BorderRadius.lg,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  padding: { padding: Spacing.md },
  badge: {
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: BorderRadius.full,
    alignSelf: 'flex-start',
  },
  badge_success: { backgroundColor: Colors.successBg },
  badge_warning: { backgroundColor: Colors.warningBg },
  badge_danger: { backgroundColor: Colors.dangerBg },
  badge_default: { backgroundColor: Colors.surface },
  badge_info: { backgroundColor: '#0C2D48' },
  badgeText: { fontSize: FontSize.xs, fontWeight: FontWeight.semibold },
  badgeText_success: { color: Colors.success },
  badgeText_warning: { color: Colors.warning },
  badgeText_danger: { color: Colors.danger },
  badgeText_default: { color: Colors.textSecondary },
  badgeText_info: { color: Colors.info },
  avatar: { backgroundColor: Colors.accentSubtle, justifyContent: 'center', alignItems: 'center' },
  avatarText: { color: Colors.accent, fontWeight: FontWeight.bold },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: Spacing.md,
    paddingTop: Spacing.md,
    paddingBottom: Spacing.sm,
  },
  headerTitle: {
    fontSize: FontSize.xxl,
    fontWeight: FontWeight.bold,
    color: Colors.textPrimary,
  },
  headerSubtitle: {
    fontSize: FontSize.sm,
    color: Colors.textSecondary,
    marginTop: 2,
  },
  emptyWrapper: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: Spacing.xxl,
  },
  emptyIcon: { marginBottom: Spacing.md },
  emptyTitle: {
    fontSize: FontSize.lg,
    fontWeight: FontWeight.semibold,
    color: Colors.textPrimary,
    textAlign: 'center',
    marginBottom: Spacing.sm,
  },
  emptyDesc: {
    fontSize: FontSize.md,
    color: Colors.textSecondary,
    textAlign: 'center',
    lineHeight: 22,
  },
  emptyAction: {
    marginTop: Spacing.lg,
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.sm,
    backgroundColor: Colors.accent,
    borderRadius: BorderRadius.md,
  },
  emptyActionText: {
    color: Colors.textPrimary,
    fontWeight: FontWeight.semibold,
    fontSize: FontSize.md,
  },
  errorTitle: {
    fontSize: FontSize.lg,
    fontWeight: FontWeight.semibold,
    color: Colors.danger,
    marginBottom: Spacing.sm,
  },
  divider: { height: 1, backgroundColor: Colors.border, marginVertical: Spacing.md },
});
