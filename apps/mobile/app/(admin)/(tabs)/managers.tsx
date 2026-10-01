import React, { useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, TextInput, RefreshControl, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useQuery } from '@tanstack/react-query';
import { adminService } from '../../../src/services/api.service';
import { Card, Avatar, Badge, EmptyState, ErrorState } from '../../../src/components/ui/index';
import { Colors, Spacing, FontSize, FontWeight, BorderRadius } from '../../../src/constants/theme';
import { Search } from 'lucide-react-native';

export default function AdminManagersScreen() {
  const [search, setSearch] = useState('');
  const { data, isLoading, error, refetch, isRefetching } = useQuery({
    queryKey: ['admin', 'managers', search],
    queryFn: () => adminService.getManagers({ search: search || undefined }),
  });
  const managers = data?.data ?? [];

  const renderItem = ({ item }: { item: any }) => (
    <Card style={styles.card}>
      <View style={styles.row}>
        <Avatar name={item.fullName} size={44} />
        <View style={styles.info}>
          <Text style={styles.name}>{item.fullName}</Text>
          <Text style={styles.email}>{item.email}</Text>
          <View style={styles.badges}>
            <Badge label={item.state.name} variant="info" />
            <Badge label={item.district.name} variant="default" />
          </View>
        </View>
        <Text style={styles.count}>{item.totalEngineers} eng</Text>
      </View>
    </Card>
  );

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.header}>
        <Text style={styles.title}>Managers</Text>
        <Text style={styles.total}>{data?.meta?.total ?? 0} total</Text>
      </View>
      <View style={styles.searchBox}>
        <Search size={16} color={Colors.textMuted} style={{ marginRight: 8 }} />
        <TextInput style={styles.searchInput} placeholder="Search..." placeholderTextColor={Colors.textMuted} value={search} onChangeText={setSearch} />
      </View>
      {isLoading && !isRefetching ? (
        <View style={styles.center}><ActivityIndicator size="large" color={Colors.accent} /></View>
      ) : error ? (
        <ErrorState message="Unable to load managers." onRetry={refetch} />
      ) : (
        <FlatList
          data={managers}
          keyExtractor={item => item.id}
          renderItem={renderItem}
          contentContainerStyle={styles.list}
          ItemSeparatorComponent={() => <View style={{ height: Spacing.sm }} />}
          refreshControl={<RefreshControl refreshing={isRefetching} onRefresh={refetch} tintColor={Colors.accent} />}
          ListEmptyComponent={!isLoading ? <EmptyState title="No managers" description="No managers registered yet." /> : null}
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
  email: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 },
  badges: { flexDirection: 'row', gap: 6, marginTop: 4 },
  count: { fontSize: FontSize.sm, color: Colors.textMuted, fontWeight: FontWeight.medium },
});