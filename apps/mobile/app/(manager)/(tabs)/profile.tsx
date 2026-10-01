import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Alert, TouchableOpacity, Platform } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { useManagerProfile, useUpdateProfile } from '../../../src/hooks/useApi';
import { useAuthStore } from '../../../src/store/auth.store';
import { Card, Avatar, Badge, Divider } from '../../../src/components/ui/index';
import { Button } from '../../../src/components/ui/Button';
import { TextInput } from '../../../src/components/ui/TextInput';
import { Colors, Spacing, FontSize, FontWeight } from '../../../src/constants/theme';
import { LogOut, Edit2, Check, X } from 'lucide-react-native';

export default function ProfileScreen() {
  const [editing, setEditing] = useState(false);
  const [fullName, setFullName] = useState('');
  const { data: profile, isLoading, refetch } = useManagerProfile();
  const updateMutation = useUpdateProfile();
  const logout = useAuthStore(s => s.logout);

  const handleLogout = async () => {
    if (Platform.OS === 'web') {
      if (window.confirm('Are you sure you want to sign out?')) {
        await logout();
        router.replace('/(auth)/login');
      }
      return;
    }
    Alert.alert('Sign Out', 'Are you sure you want to sign out?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Sign Out', style: 'destructive', onPress: async () => {
        await logout();
        router.replace('/(auth)/login');
      }},
    ]);
  };

  const startEdit = () => {
    setFullName(profile?.fullName ?? '');
    setEditing(true);
  };

  const saveEdit = async () => {
    if (!fullName.trim()) return;
    try {
      await updateMutation.mutateAsync({ fullName });
      setEditing(false);
      refetch();
    } catch {
      Alert.alert('Error', 'Failed to update profile.');
    }
  };

  if (isLoading || !profile) return null;

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <ScrollView contentContainerStyle={styles.scroll}>
        {/* Profile header */}
        <View style={styles.profileSection}>
          <Avatar name={profile.fullName} size={80} />
          {editing ? (
            <View style={styles.editRow}>
              <TextInput
                value={fullName}
                onChangeText={setFullName}
                style={{ flex: 1, marginBottom: 0 }}
                placeholder="Your name"
              />
              <TouchableOpacity onPress={saveEdit} style={styles.editBtn}>
                <Check size={18} color={Colors.success} />
              </TouchableOpacity>
              <TouchableOpacity onPress={() => setEditing(false)} style={styles.editBtn}>
                <X size={18} color={Colors.danger} />
              </TouchableOpacity>
            </View>
          ) : (
            <View style={styles.nameRow}>
              <Text style={styles.name}>{profile.fullName}</Text>
              <TouchableOpacity onPress={startEdit}>
                <Edit2 size={16} color={Colors.textMuted} />
              </TouchableOpacity>
            </View>
          )}
          <Text style={styles.email}>{profile.email}</Text>
          <View style={styles.badgeRow}>
            <Badge label="Manager" variant="info" />
            <Badge label={profile.state.name} variant="default" />
          </View>
        </View>

        <Divider />

        {/* Info */}
        <Card style={styles.infoCard}>
          <InfoRow label="Mobile" value={profile.mobile} />
          <InfoRow label="Email" value={profile.email} />
          <InfoRow label="State" value={profile.state.name} />
          <InfoRow label="District" value={profile.district.name} />
          <InfoRow label="Total Engineers" value={String(profile.totalEngineers)} />
        </Card>

        <Divider />

        <Button
          label="Sign Out"
          onPress={handleLogout}
          variant="danger"
          style={{ marginTop: Spacing.sm }}
        />
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
  scroll: { padding: Spacing.md, paddingBottom: 60 },
  profileSection: { alignItems: 'center', paddingVertical: Spacing.lg },
  nameRow: { flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: Spacing.sm },
  name: { fontSize: FontSize.xl, fontWeight: FontWeight.bold, color: Colors.textPrimary },
  email: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 4 },
  badgeRow: { flexDirection: 'row', gap: 8, marginTop: 8 },
  editRow: { flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 8, width: '80%' },
  editBtn: { padding: 8 },
  infoCard: { padding: Spacing.md, gap: 12, marginBottom: Spacing.md },
  infoRow: { flexDirection: 'row', justifyContent: 'space-between' },
  infoLabel: { fontSize: FontSize.sm, color: Colors.textMuted },
  infoValue: { fontSize: FontSize.sm, color: Colors.textPrimary, fontWeight: FontWeight.medium },
});