import React from 'react';
import { View, Text, StyleSheet, ScrollView, ActivityIndicator, FlatList } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, Stack } from 'expo-router';
import { useManagerProfileById, useManagerEngineers } from '../../../src/hooks/useApi';
import { Card, Avatar, Badge, ErrorState } from '../../../src/components/ui/index';
import { Colors, Spacing, FontSize, FontWeight } from '../../../src/constants/theme';
import { Phone, Mail } from 'lucide-react-native';

export default function ManagerProfileScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { data: manager, isLoading, error } = useManagerProfileById(id);
  const { data: engineers = [] } = useManagerEngineers(id);

  if (isLoading) return <SafeAreaView style={styles.center}><ActivityIndicator color={Colors.accent} size="large" /></SafeAreaView>;
  if (error || !manager) return <SafeAreaView style={styles.center}><ErrorState message="Manager not found." /></SafeAreaView>;

  return (
    <SafeAreaView style={styles.safe} edges={['bottom']}>
      <Stack.Screen options={{ title: manager.fullName }} />
      <ScrollView contentContainerStyle={styles.scroll}>
        <View style={styles.profileSection}>
          <Avatar name={manager.fullName} size={72} />
          <Text style={styles.name}>{manager.fullName}</Text>
          <Text style={styles.email}>{manager.email}</Text>
          <View style={styles.badges}>
            <Badge label={manager.district.name} variant="default" />
            <Badge label={manager.state.name} variant="info" />
            <Badge label={manager.totalEngineers + ' engineers'} variant="success" />
          </View>
        </View>

        <Text style={styles.sectionTitle}>Contact</Text>
        <Card style={styles.infoCard}>
          <View style={styles.infoRow}><Phone size={14} color={Colors.accent} /><Text style={styles.infoText}>{manager.mobile}</Text></View>
          <View style={styles.infoRow}><Mail size={14} color={Colors.accent} /><Text style={styles.infoText}>{manager.email}</Text></View>
        </Card>

        <Text style={styles.sectionTitle}>Engineers ({(engineers as any[]).length})</Text>
        {(engineers as any[]).map((eng: any) => (
          <Card key={eng.id} style={styles.engineerCard}>
            <View style={styles.engRow}>
              <Avatar name={eng.fullName} size={36} />
              <View style={{ flex: 1, marginLeft: 10 }}>
                <Text style={styles.engName}>{eng.fullName}</Text>
                <Text style={styles.engPhone}>{eng.phone}</Text>
                {eng.designation && <Text style={styles.engDesig}>{eng.designation}</Text>}
              </View>
              <Badge label={eng.isActive ? 'Active' : 'Inactive'} variant={eng.isActive ? 'success' : 'warning'} />
            </View>
          </Card>
        ))}
        {(engineers as any[]).length === 0 && (
          <Text style={styles.emptyText}>No engineers assigned to this manager.</Text>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: Colors.background },
  scroll: { padding: Spacing.md, paddingBottom: 40 },
  profileSection: { alignItems: 'center', paddingVertical: Spacing.lg },
  name: { fontSize: FontSize.xxl, fontWeight: FontWeight.bold, color: Colors.textPrimary, marginTop: Spacing.sm },
  email: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 4 },
  badges: { flexDirection: 'row', gap: 6, marginTop: 8, flexWrap: 'wrap', justifyContent: 'center' },
  sectionTitle: { fontSize: FontSize.sm, fontWeight: FontWeight.semibold, color: Colors.textMuted, marginBottom: Spacing.sm, marginTop: Spacing.md, textTransform: 'uppercase', letterSpacing: 0.5 },
  infoCard: { padding: Spacing.md, gap: 10, marginBottom: Spacing.sm },
  infoRow: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  infoText: { fontSize: FontSize.md, color: Colors.textPrimary },
  engineerCard: { padding: Spacing.sm, marginBottom: Spacing.sm },
  engRow: { flexDirection: 'row', alignItems: 'center' },
  engName: { fontSize: FontSize.md, fontWeight: FontWeight.medium, color: Colors.textPrimary },
  engPhone: { fontSize: FontSize.sm, color: Colors.textSecondary },
  engDesig: { fontSize: FontSize.xs, color: Colors.textMuted },
  emptyText: { textAlign: 'center', color: Colors.textMuted, marginTop: Spacing.xl },
});