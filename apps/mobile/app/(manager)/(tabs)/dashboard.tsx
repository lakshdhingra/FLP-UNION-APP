import React from 'react';
import {
  View, Text, StyleSheet, ScrollView,
  RefreshControl, ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useManagerDashboard } from '../../../src/hooks/useApi';
import { Card, Avatar, Badge, ErrorState } from '../../../src/components/ui/index';
import { Colors, Spacing, FontSize, FontWeight, BorderRadius } from '../../../src/constants/theme';
import { Users, UserCheck, Award, TrendingUp } from 'lucide-react-native';

export default function DashboardScreen() {
  const { data, isLoading, error, refetch, isRefetching } = useManagerDashboard();

  if (isLoading) {
    return (
      <SafeAreaView style={styles.center}>
        <ActivityIndicator color={Colors.accent} size="large" />
      </SafeAreaView>
    );
  }

  if (error || !data) {
    return (
      <SafeAreaView style={styles.center}>
        <ErrorState message="Unable to load dashboard." onRetry={refetch} />
      </SafeAreaView>
    );
  }

  const { manager, stats } = data;

  const topDesignation = Object.entries(stats.designationDistribution as Record<string,number>)
    .sort(([,a],[,b]) => b - a)[0];

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <ScrollView
        contentContainerStyle={styles.scroll}
        refreshControl={<RefreshControl refreshing={isRefetching} onRefresh={refetch} tintColor={Colors.accent} />}
      >
        {/* Profile card */}
        <View style={styles.profileCard}>
          <Avatar name={manager.fullName} size={56} />
          <View style={styles.profileInfo}>
            <Text style={styles.profileName}>{manager.fullName}</Text>
            <Text style={styles.profileEmail}>{manager.email}</Text>
            <View style={styles.locationRow}>
              <Badge label={manager.district.name} variant="default" />
              <Text style={styles.dot}>·</Text>
              <Badge label={manager.state.name} variant="info" />
            </View>
          </View>
        </View>

        {/* Stats row */}
        <Text style={styles.sectionTitle}>Overview</Text>
        <View style={styles.statsRow}>
          <StatCard icon={<Users size={20} color={Colors.accent} />} value={stats.totalEngineers} label="Total" color={Colors.accent} />
          <StatCard icon={<UserCheck size={20} color={Colors.success} />} value={stats.activeEngineers} label="Active" color={Colors.success} />
          <StatCard icon={<Award size={20} color={Colors.warning} />} value={stats.inactiveEngineers} label="Inactive" color={Colors.warning} />
        </View>

        {/* Experience distribution */}
        <Text style={styles.sectionTitle}>Experience</Text>
        <Card style={styles.distCard}>
          {Object.entries(stats.experienceDistribution as Record<string,number>).map(([range, count]) => (
            <View key={range} style={styles.distRow}>
              <Text style={styles.distLabel}>{range} yrs</Text>
              <View style={styles.barWrapper}>
                <View style={[styles.bar, {
                  width: stats.totalEngineers > 0 ? `${(count / stats.totalEngineers) * 100}%` : '0%',
                  backgroundColor: Colors.accent,
                }]} />
              </View>
              <Text style={styles.distCount}>{count}</Text>
            </View>
          ))}
        </Card>

        {/* Top designation */}
        {topDesignation && (
          <View style={styles.insightCard}>
            <TrendingUp size={18} color={Colors.accent} style={{ marginRight: 8 }} />
            <Text style={styles.insightText}>
              Most common role: <Text style={styles.insightHighlight}>{topDesignation[0]}</Text> ({topDesignation[1]} engineers)
            </Text>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

function StatCard({ icon, value, label, color }: { icon: React.ReactNode; value: number; label: string; color: string }) {
  return (
    <Card style={styles.statCard}>
      <View style={[styles.statIcon, { backgroundColor: `${color}20` }]}>{icon}</View>
      <Text style={[styles.statValue, { color }]}>{value}</Text>
      <Text style={styles.statLabel}>{label}</Text>
    </Card>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: Colors.background },
  scroll: { padding: Spacing.md, paddingBottom: 40 },
  profileCard: {
    flexDirection: 'row', alignItems: 'center',
    backgroundColor: Colors.card, borderRadius: BorderRadius.lg,
    padding: Spacing.md, borderWidth: 1, borderColor: Colors.border,
    marginBottom: Spacing.lg,
  },
  profileInfo: { flex: 1, marginLeft: Spacing.md },
  profileName: { fontSize: FontSize.lg, fontWeight: FontWeight.bold, color: Colors.textPrimary },
  profileEmail: { fontSize: FontSize.sm, color: Colors.textSecondary, marginBottom: 6 },
  locationRow: { flexDirection: 'row', alignItems: 'center', gap: 4 },
  dot: { color: Colors.textMuted },
  sectionTitle: {
    fontSize: FontSize.md, fontWeight: FontWeight.semibold,
    color: Colors.textSecondary, marginBottom: Spacing.sm, marginTop: Spacing.sm,
  },
  statsRow: { flexDirection: 'row', gap: Spacing.sm, marginBottom: Spacing.lg },
  statCard: { flex: 1, alignItems: 'center', padding: Spacing.md },
  statIcon: { width: 36, height: 36, borderRadius: 10, justifyContent: 'center', alignItems: 'center', marginBottom: 8 },
  statValue: { fontSize: FontSize.xxl, fontWeight: FontWeight.bold },
  statLabel: { fontSize: FontSize.xs, color: Colors.textMuted, marginTop: 2 },
  distCard: { padding: Spacing.md, marginBottom: Spacing.lg },
  distRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 10 },
  distLabel: { width: 60, fontSize: FontSize.sm, color: Colors.textSecondary },
  barWrapper: { flex: 1, height: 6, backgroundColor: Colors.surface, borderRadius: 3, overflow: 'hidden', marginHorizontal: 8 },
  bar: { height: 6, borderRadius: 3 },
  distCount: { width: 24, fontSize: FontSize.sm, color: Colors.textSecondary, textAlign: 'right' },
  insightCard: {
    flexDirection: 'row', alignItems: 'center',
    backgroundColor: Colors.accentSubtle, borderRadius: BorderRadius.md,
    padding: Spacing.md, borderWidth: 1, borderColor: `${Colors.accent}30`,
  },
  insightText: { flex: 1, fontSize: FontSize.sm, color: Colors.textSecondary },
  insightHighlight: { color: Colors.textPrimary, fontWeight: FontWeight.semibold },
});
