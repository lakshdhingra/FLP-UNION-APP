import React, { useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, TextInput, RefreshControl } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { useSameStateManagers } from '../../../src/hooks/useApi';
import { Card, Avatar, Badge, EmptyState, ErrorState } from '../../../src/components/ui/index';
import { Colors, Spacing, FontSize, FontWeight, BorderRadius } from '../../../src/constants/theme';
import { Search, ChevronRight } from 'lucide-react-native';

export default function ManagersScreen() {
  const [search, setSearch] = useState('');
  const { data, isLoading, error, refetch, isRefetching } = useSameStateManagers({ search: search || undefined });
  const managers = data?.data ?? [];

  const renderItem = ({ item }: { item: any }) => (
    <TouchableOpacity
      activeOpacity={0.8}
      onPress={() => router.push(`/(manager)/manager-profile/${item.id}`)}
    >
      <Card style={styles.card}>
        <View style={styles.cardRow}>
          <Avatar name={item.fullName} size={48} />
          <View style={styles.cardInfo}>
            <Text style={styles.cardName}>{item.fullName}</Text>
            <Text style={styles.cardEmail}>{item.email}</Text>
            <View style={styles.metaRow}>
              <Badge label={item.district.name} variant="default" />
              <Text style={styles.engineerCount}>{item.totalEngineers} engineers</Text>
            </View>
          </View>
          <ChevronRight size={18} color={Colors.textMuted} />
        </View>
      </Card>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.header}>
        <Text style={styles.title}>Manager Directory</Text>
        <Text style={styles.subtitle}>Same-state managers</Text>
      </View>
      <View style={styles.searchWrapper}>
        <Search size={16} color={Colors.textMuted} style={styles.searchIcon} />
        <TextInput
          style={styles.searchInput}
          placeholder="Search managers..."
          placeholderTextColor={Colors.textMuted}
          value={search}
          onChangeText={setSearch}
        />
      </View>
      {error ? (
        <ErrorState message="Unable to load managers." onRetry={refetch} />
      ) : (
        <FlatList
          data={managers}
          keyExtractor={item => item.id}
          renderItem={renderItem}
          contentContainerStyle={styles.list}
          ItemSeparatorComponent={() => <View style={{ height: Spacing.sm }} />}
          refreshControl={<RefreshControl refreshing={isRefetching} onRefresh={refetch} tintColor={Colors.accent} />}
          ListEmptyComponent={!isLoading ? (
            <EmptyState title={search ? 'No managers found' : 'No other managers'} description="No managers in your state yet." />
          ) : null}
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  header: { paddingHorizontal: Spacing.md, paddingTop: Spacing.md, paddingBottom: 4 },
  title: { fontSize: FontSize.xxl, fontWeight: FontWeight.bold, color: Colors.textPrimary },
  subtitle: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 },
  searchWrapper: { flexDirection: 'row', alignItems: 'center', backgroundColor: Colors.card, borderRadius: BorderRadius.md, marginHorizontal: Spacing.md, marginVertical: Spacing.sm, borderWidth: 1, borderColor: Colors.border, paddingHorizontal: Spacing.md, height: 44 },
  searchIcon: { marginRight: 8 },
  searchInput: { flex: 1, color: Colors.textPrimary, fontSize: FontSize.md },
  list: { paddingHorizontal: Spacing.md, paddingBottom: 40, flexGrow: 1 },
  card: { padding: Spacing.md },
  cardRow: { flexDirection: 'row', alignItems: 'center' },
  cardInfo: { flex: 1, marginLeft: Spacing.sm },
  cardName: { fontSize: FontSize.md, fontWeight: FontWeight.semibold, color: Colors.textPrimary },
  cardEmail: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 },
  metaRow: { flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 4 },
  engineerCount: { fontSize: FontSize.xs, color: Colors.textMuted },
});