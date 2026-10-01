import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, KeyboardAvoidingView, Platform, Alert, TouchableOpacity, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useCreateIssue, useMyIssues } from '../../../src/hooks/useApi';
import { Button } from '../../../src/components/ui/Button';
import { TextInput } from '../../../src/components/ui/TextInput';
import { Card, Badge } from '../../../src/components/ui/index';
import { Colors, Spacing, FontSize, FontWeight, BorderRadius } from '../../../src/constants/theme';
import type { Issue } from '../../../src/types/api.types';

const schema = z.object({
  type: z.enum(['ISSUE', 'SUPPORT']),
  title: z.string().min(3, 'Title required'),
  description: z.string().min(10, 'Description required (min 10 chars)'),
});
type FormData = z.infer<typeof schema>;

const statusVariant: Record<string, 'default' | 'warning' | 'success' | 'danger' | 'info'> = {
  OPEN: 'warning', IN_PROGRESS: 'info', RESOLVED: 'success', CLOSED: 'default',
};

export default function HelpScreen() {
  const [tab, setTab] = useState<'new' | 'history'>('new');
  const createMutation = useCreateIssue();
  const { data: issues = [], isLoading } = useMyIssues();
  const { control, handleSubmit, reset, setValue, watch, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { type: 'ISSUE' },
  });
  const issueType = watch('type');

  const onSubmit = async (data: FormData) => {
    try {
      await createMutation.mutateAsync(data);
      Alert.alert('Submitted', 'Your report has been submitted. We will get back to you.');
      reset();
    } catch (err: any) {
      const msg = err?.response?.data?.message ?? 'Failed to submit.';
      Alert.alert('Error', Array.isArray(msg) ? msg.join('\n') : msg);
    }
  };

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.header}>
        <Text style={styles.title}>Help & Support</Text>
      </View>
      <View style={styles.tabs}>
        <TouchableOpacity style={[styles.tab, tab === 'new' && styles.tabActive]} onPress={() => setTab('new')}>
          <Text style={[styles.tabText, tab === 'new' && styles.tabTextActive]}>New Report</Text>
        </TouchableOpacity>
        <TouchableOpacity style={[styles.tab, tab === 'history' && styles.tabActive]} onPress={() => setTab('history')}>
          <Text style={[styles.tabText, tab === 'history' && styles.tabTextActive]}>My Reports</Text>
        </TouchableOpacity>
      </View>
      {tab === 'new' ? (
        <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
          <ScrollView contentContainerStyle={styles.form} keyboardShouldPersistTaps="handled">
            <View style={styles.typeRow}>
              {(['ISSUE', 'SUPPORT'] as const).map(t => (
                <TouchableOpacity key={t} style={[styles.typeBtn, issueType === t && styles.typeBtnActive]} onPress={() => setValue('type', t)}>
                  <Text style={[styles.typeBtnText, issueType === t && styles.typeBtnTextActive]}>{t === 'ISSUE' ? 'Report Issue' : 'Request Support'}</Text>
                </TouchableOpacity>
              ))}
            </View>
            <Controller control={control} name="title" render={({ field: { onChange, onBlur, value } }) => (
              <TextInput label="Subject" placeholder="Brief summary" onChangeText={onChange} onBlur={onBlur} value={value} error={errors.title?.message} />
            )} />
            <Controller control={control} name="description" render={({ field: { onChange, onBlur, value } }) => (
              <TextInput label="Description" placeholder="Describe the issue in detail..." onChangeText={onChange} onBlur={onBlur} value={value} error={errors.description?.message} multiline numberOfLines={5} />
            )} />
            <Button label="Submit Report" onPress={handleSubmit(onSubmit)} loading={createMutation.isPending} />
          </ScrollView>
        </KeyboardAvoidingView>
      ) : (
        <ScrollView contentContainerStyle={styles.list}>
          {isLoading ? (
            <ActivityIndicator style={{ marginTop: 40 }} size="large" color={Colors.accent} />
          ) : (
            <>
              {(issues as Issue[]).map(issue => (
                <Card key={issue.id} style={styles.issueCard}>
                  <View style={styles.issueRow}>
                    <View style={{ flex: 1 }}>
                      <Text style={styles.issueTitle}>{issue.title}</Text>
                      <Text style={styles.issueDesc} numberOfLines={2}>{issue.description}</Text>
                      <Text style={styles.issueDate}>{new Date(issue.createdAt).toLocaleDateString()}</Text>
                    </View>
                    <Badge label={issue.status.replace('_', ' ')} variant={statusVariant[issue.status] ?? 'default'} />
                  </View>
                </Card>
              ))}
              {issues.length === 0 && (
                <Text style={styles.emptyText}>No reports submitted yet.</Text>
              )}
            </>
          )}
        </ScrollView>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  header: { paddingHorizontal: Spacing.md, paddingTop: Spacing.md, paddingBottom: Spacing.sm },
  title: { fontSize: FontSize.xxl, fontWeight: FontWeight.bold, color: Colors.textPrimary },
  tabs: { flexDirection: 'row', marginHorizontal: Spacing.md, backgroundColor: Colors.card, borderRadius: BorderRadius.md, padding: 4, marginBottom: Spacing.md },
  tab: { flex: 1, paddingVertical: 10, borderRadius: 8, alignItems: 'center' },
  tabActive: { backgroundColor: Colors.accent },
  tabText: { fontSize: FontSize.sm, color: Colors.textMuted, fontWeight: FontWeight.medium },
  tabTextActive: { color: Colors.textPrimary },
  form: { paddingHorizontal: Spacing.md, paddingBottom: 40 },
  typeRow: { flexDirection: 'row', gap: Spacing.sm, marginBottom: Spacing.md },
  typeBtn: { flex: 1, paddingVertical: 10, borderRadius: BorderRadius.md, borderWidth: 1, borderColor: Colors.border, alignItems: 'center' },
  typeBtnActive: { backgroundColor: Colors.accentSubtle, borderColor: Colors.accent },
  typeBtnText: { fontSize: FontSize.sm, color: Colors.textSecondary },
  typeBtnTextActive: { color: Colors.accent, fontWeight: FontWeight.semibold },
  list: { paddingHorizontal: Spacing.md, paddingBottom: 40, gap: Spacing.sm },
  issueCard: { padding: Spacing.md },
  issueRow: { flexDirection: 'row', alignItems: 'flex-start', gap: Spacing.sm },
  issueTitle: { fontSize: FontSize.md, fontWeight: FontWeight.semibold, color: Colors.textPrimary },
  issueDesc: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 4 },
  issueDate: { fontSize: FontSize.xs, color: Colors.textMuted, marginTop: 4 },
  emptyText: { textAlign: 'center', color: Colors.textMuted, marginTop: 40, fontSize: FontSize.md },
});