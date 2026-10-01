import React, { useState } from 'react';
import { View, Text, StyleSheet, FlatList, TextInput, RefreshControl, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useQuery } from '@tanstack/react-query';
import { adminService } from '../../../src/services/api.service';
import { Card, Avatar, Badge, EmptyState, ErrorState } from '../../../src/components/ui/index';
import { Colors, Spacing, FontSize, FontWeight, BorderRadius } from '../../../src/constants/theme';
import { Search } from 'lucide-react-native';

export default function AdminEngineersScreen() {
  const [search, setSearch] = useState('');
  const { data, isLoading, error, refetch, isRefetching } = useQuery({
    queryKey: ['admin', 'engineers', search],
    queryFn: () => adminService.getEngineers({ search: search || undefined }),
  });
  const engineers = data?.data ?? [];

  const renderItem = ({ item }: { item: any }) => (
    <Card style={styles.card}>
      <View style={styles.row}>
        <Avatar name={item.fullName} size={44} />
        <View style={styles.info}>
          <Text style={styles.name}>{item.fullName}</Text>
          {item.designation && <Text style={styles.designation}>{item.designation}</Text>}
          <View style={styles.badges}>
            <Badge label={item.state?.name ?? '-'} variant="info" />
            <Badge label={item.isActive ? 'Active' : 'Inactive'} variant={item.isActive ? 'success' : 'warning'} />
          </View>
          {item.manager && <Text style={styles.managerName}>Mgr: {item.manager.fullName}</Text>}
        </View>
      </View>
    </Card>
  );

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.header}>
        <Text style={styles.title}>All Engineers</Text>
        <Text style={styles.total}>{data?.meta?.total ?? 0} total</Text>
      </View>
      <View style={styles.searchBox}>
        <Search size={16} color={Colors.textMuted} style={{ marginRight: 8 }} />
        <TextInput style={styles.searchInput} placeholder="Search..." placeholderTextColor={Colors.textMuted} value={search} onChangeText={setSearch} />
      </View>
      {isLoading && !isRefetching ? (
        <View style={styles.center}><ActivityIndicator size="large" color={Colors.accent} /></View>
      ) : error ? (
        <ErrorState message="Unable to load engineers." onRetry={refetch} />
      ) : (
        <FlatList
          data={engineers}
          keyExtractor={item => item.id}
          renderItem={renderItem}
          contentContainerStyle={styles.list}
          ItemSeparatorComponent={() => <View style={{ height: Spacing.sm }} />}
          refreshControl={<RefreshControl refreshing={isRefetching} onRefresh={refetch} tintColor={Colors.accent} />}
          ListEmptyComponent={!isLoading ? <EmptyState title="No engineers" description="No engineers registered yet." /> : null}
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: Spacing.md, paddingTop: Spacing.md },
  title: { fontSize: FontSize.xxl, fontWeight: FontWeight.bold, color: Colors.textPrimary },
  total: { fontSize: FontSize.sm, color: Colors.textMuted },
  searchBox: { flexDirection: 'row', alignItems: 'center', backgroundColor: Colors.card, borderRadius: BorderRadius.md, marginHorizontal: Spacing.md, marginVertical: Spacing.sm, borderWidth: 1, borderColor: Colors.border, paddingHorizontal: Spacing.md, height: 44 },
  searchInput: { flex: 1, color: Colors.textPrimary, fontSize: FontSize.md },
  list: { paddingHorizontal: Spacing.md, paddingBottom: 40, flexGrow: 1 },
  card: { padding: Spacing.md },
  row: { flexDirection: 'row', alignItems: 'center' },
  info: { flex: 1, marginLeft: Spacing.sm },
  name: { fontSize: FontSize.md, fontWeight: FontWeight.semibold, color: Colors.textPrimary },
  designation: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 },
  badges: { flexDirection: 'row', gap: 6, marginTop: 4 },
  managerName: { fontSize: FontSize.xs, color: Colors.textMuted, marginTop: 4 },
});