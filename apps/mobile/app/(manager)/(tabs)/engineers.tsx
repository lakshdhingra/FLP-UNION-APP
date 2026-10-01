import React, { useState } from 'react';
import {
  View, Text, StyleSheet, FlatList, TouchableOpacity,
  TextInput, RefreshControl, Alert, ActivityIndicator
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { useMyEngineers, useDeleteEngineer } from '../../../src/hooks/useApi';
import { Card, Avatar, Badge, EmptyState, ErrorState } from '../../../src/components/ui/index';
import { Colors, Spacing, FontSize, FontWeight, BorderRadius } from '../../../src/constants/theme';
import { Plus, Search, ChevronRight, Trash2, Pencil } from 'lucide-react-native';
import type { Engineer } from '../../../src/types/api.types';

export default function EngineersScreen() {
  const [search, setSearch] = useState('');
  const { data, isLoading, error, refetch, isRefetching } = useMyEngineers({ search: search || undefined });
  const engineers = data?.data ?? [];
  const deleteMutation = useDeleteEngineer();

  const handleDelete = (id: string, name: string) => {
    Alert.alert('Delete Engineer', `Remove ${name}? This cannot be undone.`, [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete', style: 'destructive',
        onPress: () => deleteMutation.mutate(id, {
          onError: () => Alert.alert('Error', 'Failed to delete engineer.'),
        }),
      },
    ]);
  };

  const renderItem = ({ item }: { item: Engineer }) => (
    <TouchableOpacity
      activeOpacity={0.8}
      onPress={() => router.push(`/(manager)/engineer/${item.id}`)}
    >
      <Card style={styles.card}>
        <View style={styles.cardRow}>
          <Avatar name={item.fullName} size={44} />
          <View style={styles.cardInfo}>
            <Text style={styles.cardName}>{item.fullName}</Text>
            {item.designation && <Text style={styles.cardDesignation}>{item.designation}</Text>}
            <View style={styles.cardMeta}>
              {item.district && <Text style={styles.metaText}>{item.district.name}</Text>}
              {item.experienceYears != null && (
                <Text style={styles.metaText}>{item.experienceYears} yrs exp</Text>
              )}
              <Badge label={item.isActive ? 'Active' : 'Inactive'} variant={item.isActive ? 'success' : 'warning'} />
            </View>
          </View>
          <View style={styles.actions}>
            <TouchableOpacity
              style={styles.actionBtn}
              onPress={() => router.push(`/(manager)/engineer/edit?id=${item.id}`)}
            >
              <Pencil size={16} color={Colors.accent} />
            </TouchableOpacity>
            <TouchableOpacity
              style={styles.actionBtn}
              onPress={() => handleDelete(item.id, item.fullName)}
            >
              <Trash2 size={16} color={Colors.danger} />
            </TouchableOpacity>
          </View>
        </View>
      </Card>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>My Engineers</Text>
        <TouchableOpacity
          style={styles.addBtn}
          onPress={() => router.push('/(manager)/engineer/create')}
          activeOpacity={0.8}
        >
          <Plus size={20} color={Colors.textPrimary} />
        </TouchableOpacity>
      </View>

      {/* Search */}
      <View style={styles.searchWrapper}>
        <Search size={16} color={Colors.textMuted} style={styles.searchIcon} />
        <TextInput
          style={styles.searchInput}
          placeholder="Search engineers..."
          placeholderTextColor={Colors.textMuted}
          value={search}
          onChangeText={setSearch}
        />
      </View>

      {isLoading && !isRefetching ? (
        <View style={styles.center}><ActivityIndicator size="large" color={Colors.accent} /></View>
      ) : error ? (
        <ErrorState message="Unable to load engineers." onRetry={refetch} />
      ) : (
        <FlatList
          data={engineers as Engineer[]}
          keyExtractor={item => item.id}
          renderItem={renderItem}
          contentContainerStyle={styles.list}
          ItemSeparatorComponent={() => <View style={{ height: Spacing.sm }} />}
          refreshControl={<RefreshControl refreshing={isRefetching} onRefresh={refetch} tintColor={Colors.accent} />}
          ListEmptyComponent={
            !isLoading ? (
              <EmptyState
                title={search ? 'No engineers found' : 'No engineers yet'}
                description={search ? 'Try a different search term.' : 'Tap the + button to add your first engineer.'}
                action={!search ? { label: 'Add Engineer', onPress: () => router.push('/(manager)/engineer/create') } : undefined}
              />
            ) : null
          }
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: Spacing.md },
  title: { fontSize: FontSize.xxl, fontWeight: FontWeight.bold, color: Colors.textPrimary },
  addBtn: {
    width: 40, height: 40, borderRadius: 20,
    backgroundColor: Colors.accent,
    justifyContent: 'center', alignItems: 'center',
  },
  searchWrapper: {
    flexDirection: 'row', alignItems: 'center',
    backgroundColor: Colors.card, borderRadius: BorderRadius.md,
    marginHorizontal: Spacing.md, marginBottom: Spacing.sm,
    borderWidth: 1, borderColor: Colors.border, paddingHorizontal: Spacing.md, height: 44,
  },
  searchIcon: { marginRight: 8 },
  searchInput: { flex: 1, color: Colors.textPrimary, fontSize: FontSize.md },
  list: { paddingHorizontal: Spacing.md, paddingBottom: 40, flexGrow: 1 },
  card: { padding: Spacing.md },
  cardRow: { flexDirection: 'row', alignItems: 'center' },
  cardInfo: { flex: 1, marginLeft: Spacing.sm },
  cardName: { fontSize: FontSize.md, fontWeight: FontWeight.semibold, color: Colors.textPrimary },
  cardDesignation: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 },
  cardMeta: { flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: 4, flexWrap: 'wrap' },
  metaText: { fontSize: FontSize.xs, color: Colors.textMuted },
  actions: { flexDirection: 'row', gap: 8 },
  actionBtn: {
    width: 32, height: 32, borderRadius: 8,
    backgroundColor: Colors.surface,
    justifyContent: 'center', alignItems: 'center',
  },
});
