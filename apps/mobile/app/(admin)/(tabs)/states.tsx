import React, { useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl, Alert } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../../../src/services/api.service';
import { Card, Badge, ErrorState } from '../../../src/components/ui/index';
import { Colors, Spacing, FontSize, FontWeight } from '../../../src/constants/theme';
import { Building2, Plus, Power, PowerOff } from 'lucide-react-native';

export default function AdminStatesScreen() {
  const qc = useQueryClient();
  const { data: states, isLoading, error, refetch, isRefetching } = useQuery({
    queryKey: ['admin', 'states'],
    queryFn: () => adminService.getStates(true), // include inactive
  });

  const toggleMutation = useMutation({
    mutationFn: ({ id, isActive }: { id: string; isActive: boolean }) => adminService.updateState(id, { isActive }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'states'] }),
  });

  const handleToggle = (id: string, name: string, currentStatus: boolean) => {
    Alert.alert(
      currentStatus ? 'Deactivate State' : 'Activate State',
      `Are you sure you want to ${currentStatus ? 'deactivate' : 'activate'} ${name}?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: currentStatus ? 'Deactivate' : 'Activate',
          style: currentStatus ? 'destructive' : 'default',
          onPress: () => toggleMutation.mutate({ id, isActive: !currentStatus }),
        },
      ]
    );
  };

  const renderItem = ({ item }: { item: any }) => (
    <Card style={styles.card}>
      <View style={styles.row}>
        <View style={styles.iconBox}>
          <Building2 size={20} color={Colors.accent} />
        </View>
        <View style={styles.info}>
          <Text style={styles.name}>{item.name}</Text>
          <View style={styles.stats}>
            <Text style={styles.statText}>{item._count.districts} districts</Text>
            <Text style={styles.statText}>•</Text>
            <Text style={styles.statText}>{item._count.managerProfiles} managers</Text>
          </View>
        </View>
        <View style={styles.actions}>
          <Badge label={item.isActive ? 'Active' : 'Inactive'} variant={item.isActive ? 'success' : 'default'} />
          <TouchableOpacity
            style={[styles.toggleBtn, item.isActive ? styles.btnDanger : styles.btnSuccess]}
            onPress={() => handleToggle(item.id, item.name, item.isActive)}
          >
            {item.isActive ? <PowerOff size={14} color={Colors.danger} /> : <Power size={14} color={Colors.success} />}
          </TouchableOpacity>
        </View>
      </View>
    </Card>
  );

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.header}>
        <Text style={styles.title}>States & Regions</Text>
        <TouchableOpacity style={styles.addBtn} onPress={() => Alert.alert('Coming Soon', 'Adding states from mobile will be available in next update.')}>
          <Plus size={20} color={Colors.textPrimary} />
        </TouchableOpacity>
      </View>
      {error ? (
        <ErrorState message="Unable to load states." onRetry={refetch} />
      ) : (
        <FlatList
          data={states}
          keyExtractor={item => item.id}
          renderItem={renderItem}
          contentContainerStyle={styles.list}
          ItemSeparatorComponent={() => <View style={{ height: Spacing.sm }} />}
          refreshControl={<RefreshControl refreshing={isRefetching} onRefresh={refetch} tintColor={Colors.accent} />}
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: Spacing.md },
  title: { fontSize: FontSize.xxl, fontWeight: FontWeight.bold, color: Colors.textPrimary },
  addBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.accent, justifyContent: 'center', alignItems: 'center' },
  list: { paddingHorizontal: Spacing.md, paddingBottom: 40, flexGrow: 1 },
  card: { padding: Spacing.md },
  row: { flexDirection: 'row', alignItems: 'center' },
  iconBox: { width: 44, height: 44, borderRadius: 12, backgroundColor: Colors.accentSubtle, justifyContent: 'center', alignItems: 'center' },
  info: { flex: 1, marginLeft: Spacing.sm },
  name: { fontSize: FontSize.md, fontWeight: FontWeight.semibold, color: Colors.textPrimary },
  stats: { flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: 4 },
  statText: { fontSize: FontSize.xs, color: Colors.textSecondary },
  actions: { alignItems: 'flex-end', gap: 8 },
  toggleBtn: { padding: 6, borderRadius: 8, borderWidth: 1 },
  btnDanger: { backgroundColor: Colors.dangerBg, borderColor: Colors.danger },
  btnSuccess: { backgroundColor: Colors.successBg, borderColor: Colors.success },
});