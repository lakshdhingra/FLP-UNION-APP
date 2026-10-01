import React from 'react';
import { View, Text, StyleSheet, ScrollView, RefreshControl, ActivityIndicator, Alert, TouchableOpacity, Platform } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { adminService } from '../../../src/services/api.service';
import { Card, Badge, ErrorState } from '../../../src/components/ui/index';
import { Button } from '../../../src/components/ui/Button';
import { useAuthStore } from '../../../src/store/auth.store';
import { Colors, Spacing, FontSize, FontWeight, BorderRadius } from '../../../src/constants/theme';
import { Users, Building2, Map, AlertCircle, UserCheck, LogOut } from 'lucide-react-native';

export default function AdminDashboardScreen() {
  const { data, isLoading, error, refetch, isRefetching } = useQuery({
    queryKey: ['admin', 'summary'],
    queryFn: adminService.getSummary,
  });
  const logout = useAuthStore(s => s.logout);

  const handleLogout = async () => {
    if (Platform.OS === 'web') {
      if (window.confirm('Sign out of admin?')) {
        await logout();
        router.replace('/(auth)/login');
      }
      return;
    }
    Alert.alert('Sign Out', 'Sign out of admin?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Sign Out', style: 'destructive', onPress: async () => {
        await logout();
        router.replace('/(auth)/login');
      }},
    ]);
  };

  if (isLoading) return <SafeAreaView style={styles.center}><ActivityIndicator color={Colors.accent} size="large" /></SafeAreaView>;
  if (error || !data) return <SafeAreaView style={styles.center}><ErrorState message="Unable to load analytics." onRetry={refetch} /></SafeAreaView>;

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <ScrollView
        contentContainerStyle={styles.scroll}
        refreshControl={<RefreshControl refreshing={isRefetching} onRefresh={refetch} tintColor={Colors.accent} />}
      >
        <View style={styles.header}>
          <View>
            <Text style={styles.title}>Admin Dashboard</Text>
            <Text style={styles.subtitle}>TASPU Platform Overview</Text>
          </View>
          <TouchableOpacity onPress={handleLogout} style={styles.logoutBtn}>
            <LogOut size={20} color={Colors.danger} />
          </TouchableOpacity>
        </View>

        <View style={styles.grid}>
          <StatCard label="States" value={data.states} icon={<Map size={20} color={Colors.info} />} color={Colors.info} />
          <StatCard label="Managers" value={data.managers} icon={<UserCheck size={20} color={Colors.accent} />} color={Colors.accent} />
          <StatCard label="Engineers" value={data.engineers} icon={<Users size={20} color={Colors.success} />} color={Colors.success} />
          <StatCard label="Open Issues" value={data.openIssues} icon={<AlertCircle size={20} color={Colors.warning} />} color={Colors.warning} />
        </View>

        <View style={styles.engStats}>
          <Card style={styles.engCard}>
            <Text style={styles.cardLabel}>Active Engineers</Text>
            <Text style={[styles.cardValue, { color: Colors.success }]}>{data.activeEngineers}</Text>
          </Card>
          <Card style={styles.engCard}>
            <Text style={styles.cardLabel}>Inactive</Text>
            <Text style={[styles.cardValue, { color: Colors.warning }]}>{data.inactiveEngineers}</Text>
          </Card>
        </View>

        <Text style={styles.sectionTitle}>Engineers by State</Text>
        <Card style={styles.stateList}>
          {(data.engineersByState as { state: string; count: number }[]).map((s) => (
            <View key={s.state} style={styles.stateRow}>
              <Text style={styles.stateName}>{s.state}</Text>
              <View style={styles.stateBarWrapper}>
                <View style={[styles.stateBar, {
                  width: data.engineers > 0 ? `${(s.count / data.engineers) * 100}%` : '0%',
                  backgroundColor: Colors.accent,
                }]} />
              </View>
              <Text style={styles.stateCount}>{s.count}</Text>
            </View>
          ))}
        </Card>
      </ScrollView>
    </SafeAreaView>
  );
}

function StatCard({ label, value, icon, color }: { label: string; value: number; icon: React.ReactNode; color: string }) {
  return (
    <Card style={styles.statCard}>
      <View style={[styles.statIcon, { backgroundColor: color + '20' }]}>{icon}</View>
      <Text style={[styles.statValue, { color }]}>{value}</Text>
      <Text style={styles.statLabel}>{label}</Text>
    </Card>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: Colors.background },
  scroll: { padding: Spacing.md, paddingBottom: 60 },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: Spacing.lg },
  title: { fontSize: FontSize.xxl, fontWeight: FontWeight.bold, color: Colors.textPrimary },
  subtitle: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 },
  logoutBtn: { padding: Spacing.sm },
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: Spacing.sm, marginBottom: Spacing.md },
  statCard: { width: '47%', padding: Spacing.md, alignItems: 'center' },
  statIcon: { width: 36, height: 36, borderRadius: 10, justifyContent: 'center', alignItems: 'center', marginBottom: 8 },
  statValue: { fontSize: FontSize.xxl, fontWeight: FontWeight.bold },
  statLabel: { fontSize: FontSize.xs, color: Colors.textMuted, marginTop: 2 },
  engStats: { flexDirection: 'row', gap: Spacing.sm, marginBottom: Spacing.md },
  engCard: { flex: 1, padding: Spacing.md, alignItems: 'center' },
  cardLabel: { fontSize: FontSize.xs, color: Colors.textMuted, marginBottom: 4 },
  cardValue: { fontSize: FontSize.xl, fontWeight: FontWeight.bold },
  sectionTitle: { fontSize: FontSize.sm, fontWeight: FontWeight.semibold, color: Colors.textMuted, marginBottom: Spacing.sm, textTransform: 'uppercase', letterSpacing: 0.5 },
  stateList: { padding: Spacing.md, gap: 10 },
  stateRow: { flexDirection: 'row', alignItems: 'center' },
  stateName: { width: 80, fontSize: FontSize.sm, color: Colors.textSecondary },
  stateBarWrapper: { flex: 1, height: 6, backgroundColor: Colors.surface, borderRadius: 3, overflow: 'hidden', marginHorizontal: 8 },
  stateBar: { height: 6, borderRadius: 3 },
  stateCount: { width: 24, fontSize: FontSize.sm, color: Colors.textSecondary, textAlign: 'right' },
});