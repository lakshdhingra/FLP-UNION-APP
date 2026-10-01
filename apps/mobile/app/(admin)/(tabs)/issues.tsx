import React, { useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl, Alert, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../../../src/services/api.service';
import { Card, Badge, EmptyState, ErrorState } from '../../../src/components/ui/index';
import { Colors, Spacing, FontSize, FontWeight, BorderRadius } from '../../../src/constants/theme';
import { CheckCircle, Clock } from 'lucide-react-native';

const statusVariant: Record<string, 'default' | 'warning' | 'success' | 'danger' | 'info'> = {
  OPEN: 'warning', IN_PROGRESS: 'info', RESOLVED: 'success', CLOSED: 'default',
};

export default function AdminIssuesScreen() {
  const [filter, setFilter] = useState<string>(''); // '' = all, 'OPEN' = open only
  const qc = useQueryClient();

  const { data, isLoading, error, refetch, isRefetching } = useQuery({
    queryKey: ['admin', 'issues', filter],
    queryFn: () => adminService.getIssues(filter ? { status: filter } : undefined),
  });
  const issues = data?.data ?? [];

  const updateStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) => adminService.updateIssueStatus(id, status),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'issues'] }),
  });

  const handleUpdateStatus = (id: string, currentStatus: string) => {
    if (currentStatus === 'RESOLVED') return;
    const nextStatus = currentStatus === 'OPEN' ? 'IN_PROGRESS' : 'RESOLVED';
    Alert.alert('Update Status', `Mark this issue as ${nextStatus.replace('_', ' ')}?`, [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Update', onPress: () => updateStatusMutation.mutate({ id, status: nextStatus }) },
    ]);
  };

  const renderItem = ({ item }: { item: any }) => (
    <Card style={styles.card}>
      <View style={styles.header}>
        <View style={styles.typeRow}>
          <Text style={styles.type}>{item.type}</Text>
          <Badge label={item.status.replace('_', ' ')} variant={statusVariant[item.status] ?? 'default'} />
        </View>
        <Text style={styles.date}>{new Date(item.createdAt).toLocaleDateString()}</Text>
      </View>
      <Text style={styles.title}>{item.title}</Text>
      <Text style={styles.desc}>{item.description}</Text>
      <View style={styles.reporter}>
        <Text style={styles.reporterLabel}>Reporter: </Text>
        <Text style={styles.reporterName}>{item.reporter?.managerProfile?.fullName ?? item.reporter?.email ?? 'Unknown'}</Text>
      </View>
      {item.status !== 'RESOLVED' && item.status !== 'CLOSED' && (
        <TouchableOpacity
          style={styles.actionBtn}
          onPress={() => handleUpdateStatus(item.id, item.status)}
          disabled={updateStatusMutation.isPending}
        >
          {item.status === 'OPEN' ? <Clock size={16} color={Colors.accent} /> : <CheckCircle size={16} color={Colors.success} />}
          <Text style={[styles.actionText, { color: item.status === 'OPEN' ? Colors.accent : Colors.success }]}>
            {item.status === 'OPEN' ? 'Mark In Progress' : 'Mark Resolved'}
          </Text>
        </TouchableOpacity>
      )}
    </Card>
  );

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.pageHeader}>
        <Text style={styles.pageTitle}>Support Issues</Text>
        <View style={styles.filters}>
          <TouchableOpacity style={[styles.filterBtn, !filter && styles.filterBtnActive]} onPress={() => setFilter('')}>
            <Text style={[styles.filterText, !filter && styles.filterTextActive]}>All</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[styles.filterBtn, filter === 'OPEN' && styles.filterBtnActive]} onPress={() => setFilter('OPEN')}>
            <Text style={[styles.filterText, filter === 'OPEN' && styles.filterTextActive]}>Open Only</Text>
          </TouchableOpacity>
        </View>
      </View>

      {isLoading && !isRefetching ? (
        <View style={styles.center}><ActivityIndicator size="large" color={Colors.accent} /></View>
      ) : error ? (
        <ErrorState message="Unable to load issues." onRetry={refetch} />
      ) : (
        <FlatList
          data={issues}
          keyExtractor={item => item.id}
          renderItem={renderItem}
          contentContainerStyle={styles.list}
          ItemSeparatorComponent={() => <View style={{ height: Spacing.sm }} />}
          refreshControl={<RefreshControl refreshing={isRefetching} onRefresh={refetch} tintColor={Colors.accent} />}
          ListEmptyComponent={!isLoading ? <EmptyState title="No issues" description="No support requests found." /> : null}
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  pageHeader: { padding: Spacing.md },
  pageTitle: { fontSize: FontSize.xxl, fontWeight: FontWeight.bold, color: Colors.textPrimary, marginBottom: Spacing.sm },
  filters: { flexDirection: 'row', gap: 8 },
  filterBtn: { paddingHorizontal: 12, paddingVertical: 6, borderRadius: 16, backgroundColor: Colors.surface, borderWidth: 1, borderColor: Colors.border },
  filterBtnActive: { backgroundColor: Colors.accentSubtle, borderColor: Colors.accent },
  filterText: { fontSize: FontSize.xs, color: Colors.textSecondary },
  filterTextActive: { color: Colors.accent, fontWeight: FontWeight.semibold },
  list: { paddingHorizontal: Spacing.md, paddingBottom: 40, flexGrow: 1 },
  card: { padding: Spacing.md },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 },
  typeRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  type: { fontSize: FontSize.xs, fontWeight: 'bold', color: Colors.textMuted, letterSpacing: 0.5 },
  date: { fontSize: FontSize.xs, color: Colors.textMuted },
  title: { fontSize: FontSize.md, fontWeight: FontWeight.semibold, color: Colors.textPrimary, marginBottom: 4 },
  desc: { fontSize: FontSize.sm, color: Colors.textSecondary, marginBottom: Spacing.sm },
  reporter: { flexDirection: 'row', padding: 8, backgroundColor: Colors.surface, borderRadius: 6, marginBottom: 8 },
  reporterLabel: { fontSize: FontSize.xs, color: Colors.textMuted },
  reporterName: { fontSize: FontSize.xs, color: Colors.textPrimary, fontWeight: FontWeight.medium },
  actionBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', paddingVertical: 10, gap: 8, backgroundColor: Colors.surface, borderRadius: BorderRadius.md, borderWidth: 1, borderColor: Colors.border, marginTop: Spacing.sm },
  actionText: { fontSize: FontSize.sm, fontWeight: FontWeight.semibold },
});
