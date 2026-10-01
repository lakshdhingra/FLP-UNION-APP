import React from 'react';
import { View, Text, StyleSheet, ScrollView, ActivityIndicator, RefreshControl } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, Stack } from 'expo-router';
import { useEngineer } from '../../../src/hooks/useApi';
import { Card, Avatar, Badge, ErrorState, Divider } from '../../../src/components/ui/index';
import { Colors, Spacing, FontSize, FontWeight } from '../../../src/constants/theme';
import { Lock } from 'lucide-react-native';

export default function EngineerDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { data: engineer, isLoading, error, refetch, isRefetching } = useEngineer(id);

  if (isLoading) return (
    <SafeAreaView style={styles.center}>
      <ActivityIndicator color={Colors.accent} size="large" />
    </SafeAreaView>
  );
  if (error || !engineer) return (
    <SafeAreaView style={styles.center}>
      <ErrorState message="Engineer not found." onRetry={refetch} />
    </SafeAreaView>
  );
  const isMasked = engineer.isOwned === false;
  return (
    <SafeAreaView style={styles.safe} edges={['bottom']}>
      <Stack.Screen options={{ title: engineer.fullName }} />
      <ScrollView contentContainerStyle={styles.scroll} refreshControl={<RefreshControl refreshing={isRefetching} onRefresh={refetch} tintColor={Colors.accent} />}>
        <View style={styles.profileSection}>
          <Avatar name={engineer.fullName} size={72} />
          <Text style={styles.name}>{engineer.fullName}</Text>
          {engineer.designation && <Text style={styles.designation}>{engineer.designation}</Text>}
          <View style={styles.badgeRow}>
            <Badge label={engineer.isActive ? 'Active' : 'Inactive'} variant={engineer.isActive ? 'success' : 'warning'} />
            {isMasked && <Badge label="External Engineer" variant="default" />}
          </View>
          {isMasked && (
            <View style={styles.readOnlyBanner}>
              <Lock size={14} color={Colors.textMuted} />
              <Text style={styles.readOnlyText}>Sensitive information is hidden because this engineer belongs to another manager.</Text>
            </View>
          )}
        </View>
        <Divider />
        <Card style={styles.section}>
          <InfoRow label="Phone" value={engineer.phone} />
          {engineer.email && <InfoRow label="Email" value={engineer.email} />}
          {!isMasked && engineer.address && <InfoRow label="Address" value={engineer.address} />}
        </Card>
        <Card style={styles.section}>
          <InfoRow label="District" value={engineer.district?.name ?? '-'} />
          <InfoRow label="State" value={engineer.state?.name ?? '-'} />
          {engineer.experienceYears != null && <InfoRow label="Experience" value={engineer.experienceYears + ' years'} />}
          {(engineer.skills?.length ?? 0) > 0 && <InfoRow label="Skills" value={engineer.skills.join(', ')} />}
        </Card>
        {!isMasked && (engineer.govIdType || engineer.salary != null || engineer.privateNotes) && (
          <Card style={styles.section}>
            {engineer.govIdType && <InfoRow label={engineer.govIdType} value={engineer.govIdNumber ?? '-'} />}
            {engineer.salary != null && <InfoRow label="Salary" value={'Rs.' + Number(engineer.salary).toLocaleString()} />}
            {engineer.privateNotes && <InfoRow label="Notes" value={engineer.privateNotes} />}
          </Card>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

function InfoRow({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.infoRow}>
      <Text style={styles.infoLabel}>{label}</Text>
      <Text style={styles.infoValue}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: Colors.background },
  scroll: { padding: Spacing.md, paddingBottom: 40 },
  profileSection: { alignItems: 'center', paddingVertical: Spacing.lg },
  name: { fontSize: FontSize.xxl, fontWeight: FontWeight.bold, color: Colors.textPrimary, marginTop: Spacing.sm },
  designation: { fontSize: FontSize.md, color: Colors.textSecondary, marginTop: 4 },
  badgeRow: { flexDirection: 'row', gap: 8, marginTop: 8 },
  readOnlyBanner: { flexDirection: 'row', alignItems: 'flex-start', gap: 8, backgroundColor: Colors.surface, borderRadius: 8, padding: Spacing.sm, marginTop: Spacing.md, maxWidth: '90%' },
  readOnlyText: { flex: 1, fontSize: FontSize.xs, color: Colors.textMuted, lineHeight: 16 },
  section: { padding: Spacing.md, marginBottom: Spacing.md, gap: 12 },
  infoRow: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 4 },
  infoLabel: { fontSize: FontSize.sm, color: Colors.textMuted, flex: 1 },
  infoValue: { fontSize: FontSize.sm, color: Colors.textPrimary, flex: 2, textAlign: 'right' },
});