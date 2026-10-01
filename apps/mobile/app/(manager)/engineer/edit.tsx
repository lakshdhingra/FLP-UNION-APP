import React, { useState, useEffect } from 'react';
import {
  View, Text, StyleSheet, ScrollView,
  KeyboardAvoidingView, Platform, Alert, TouchableOpacity, ActivityIndicator
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, Stack, useLocalSearchParams } from 'expo-router';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useEngineer, useUpdateEngineer, useDistricts, useManagerProfile } from '../../../src/hooks/useApi';
import { Button } from '../../../src/components/ui/Button';
import { TextInput } from '../../../src/components/ui/TextInput';
import { Colors, Spacing, FontSize, FontWeight, BorderRadius } from '../../../src/constants/theme';
import { ChevronDown } from 'lucide-react-native';

const schema = z.object({
  fullName: z.string().min(2, 'Name required'),
  phone: z.string().regex(/^\+?[0-9]{7,15}$/, 'Valid phone required'),
  email: z.string().email().optional().or(z.literal('')),
  districtId: z.string().uuid('Select district'),
  designation: z.string().optional(),
  experienceYears: z.string().optional(),
  skills: z.string().optional(),
  address: z.string().optional(),
  salary: z.string().optional(),
  privateNotes: z.string().optional(),
});
type FormData = z.infer<typeof schema>;

export default function EditEngineerScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const [districtPickerOpen, setDistrictPickerOpen] = useState(false);
  const [selectedDistrictName, setSelectedDistrictName] = useState('');
  
  const { data: profile } = useManagerProfile();
  const { data: districts = [] } = useDistricts(profile?.state?.id);
  const { data: engineer, isLoading, error } = useEngineer(id);
  const updateMutation = useUpdateEngineer(id);

  const { control, handleSubmit, setValue, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  useEffect(() => {
    if (engineer) {
      setValue('fullName', engineer.fullName);
      setValue('phone', engineer.phone);
      setValue('email', engineer.email || '');
      setValue('districtId', engineer.district?.id || '');
      setValue('designation', engineer.designation || '');
      setValue('experienceYears', engineer.experienceYears?.toString() || '');
      setValue('skills', engineer.skills?.join(', ') || '');
      setValue('address', engineer.address || '');
      setValue('salary', engineer.salary?.toString() || '');
      setValue('privateNotes', engineer.privateNotes || '');
      setSelectedDistrictName(engineer.district?.name || '');
    }
  }, [engineer, setValue]);

  const onSubmit = async (data: FormData) => {
    try {
      const payload: Record<string, unknown> = {
        fullName: data.fullName,
        phone: data.phone,
        districtId: data.districtId,
      };
      if (data.email) payload.email = data.email;
      if (data.designation) payload.designation = data.designation;
      if (data.address) payload.address = data.address;
      if (data.skills) payload.skills = data.skills.split(',').map((s: string) => s.trim()).filter(Boolean);
      if (data.experienceYears) payload.experienceYears = parseFloat(data.experienceYears);
      if (data.salary) payload.salary = parseFloat(data.salary);
      if (data.privateNotes) payload.privateNotes = data.privateNotes;

      await updateMutation.mutateAsync(payload);
      router.back();
    } catch (err: any) {
      const msg = err?.response?.data?.message ?? 'Failed to update engineer.';
      Alert.alert('Error', Array.isArray(msg) ? msg.join('\n') : msg);
    }
  };

  if (isLoading) {
    return (
      <SafeAreaView style={styles.center}>
        <ActivityIndicator color={Colors.accent} size="large" />
      </SafeAreaView>
    );
  }

  if (error || !engineer) {
    return (
      <SafeAreaView style={styles.center}>
        <Text>Engineer not found.</Text>
      </SafeAreaView>
    );
  }

  return (
    <KeyboardAvoidingView style={{ flex: 1, backgroundColor: Colors.background }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <Stack.Screen options={{ title: 'Edit Engineer' }} />
      <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
        <Controller control={control} name="fullName" render={({ field: { onChange, onBlur, value } }) => (
          <TextInput label="Full Name *" placeholder="Engineer full name" onChangeText={onChange} onBlur={onBlur} value={value} error={errors.fullName?.message} />
        )} />
        <Controller control={control} name="phone" render={({ field: { onChange, onBlur, value } }) => (
          <TextInput label="Phone *" placeholder="+91 9999999999" keyboardType="phone-pad" onChangeText={onChange} onBlur={onBlur} value={value} error={errors.phone?.message} />
        )} />
        <Controller control={control} name="email" render={({ field: { onChange, onBlur, value } }) => (
          <TextInput label="Email" placeholder="email@example.com" keyboardType="email-address" autoCapitalize="none" onChangeText={onChange} onBlur={onBlur} value={value} error={errors.email?.message} />
        )} />
        <Controller control={control} name="designation" render={({ field: { onChange, onBlur, value } }) => (
          <TextInput label="Designation" placeholder="e.g. Senior Engineer" onChangeText={onChange} onBlur={onBlur} value={value} />
        )} />
        <Controller control={control} name="experienceYears" render={({ field: { onChange, onBlur, value } }) => (
          <TextInput label="Experience (years)" placeholder="e.g. 5.5" keyboardType="decimal-pad" onChangeText={onChange} onBlur={onBlur} value={value} />
        )} />
        <Controller control={control} name="skills" render={({ field: { onChange, onBlur, value } }) => (
          <TextInput label="Skills (comma-separated)" placeholder="e.g. React, Node.js, SQL" onChangeText={onChange} onBlur={onBlur} value={value} />
        )} />

        {/* District */}
        <Controller control={control} name="districtId" render={({ field: { onChange } }) => (
          <View style={styles.pickerWrapper}>
            <Text style={styles.label}>District *</Text>
            <TouchableOpacity style={styles.picker} onPress={() => setDistrictPickerOpen(!districtPickerOpen)}>
              <Text style={[styles.pickerText, !selectedDistrictName && styles.pickerPlaceholder]}>
                {selectedDistrictName || 'Select District'}
              </Text>
              <ChevronDown size={18} color={Colors.textMuted} />
            </TouchableOpacity>
            {errors.districtId && <Text style={styles.errorText}>{errors.districtId.message}</Text>}
            {districtPickerOpen && (
              <ScrollView style={styles.dropdown} nestedScrollEnabled={true}>
                {(districts as any[]).map((d) => (
                  <TouchableOpacity
                    key={d.id}
                    style={styles.dropdownItem}
                    onPress={() => {
                      onChange(d.id);
                      setSelectedDistrictName(d.name);
                      setDistrictPickerOpen(false);
                    }}
                  >
                    <Text style={styles.dropdownItemText}>{d.name}</Text>
                  </TouchableOpacity>
                ))}
              </ScrollView>
            )}
          </View>
        )} />

        <Controller control={control} name="address" render={({ field: { onChange, onBlur, value } }) => (
          <TextInput label="Address" placeholder="Full address" multiline numberOfLines={3} onChangeText={onChange} onBlur={onBlur} value={value} />
        )} />
        <Controller control={control} name="salary" render={({ field: { onChange, onBlur, value } }) => (
          <TextInput label="Salary" placeholder="e.g. 50000" keyboardType="decimal-pad" onChangeText={onChange} onBlur={onBlur} value={value} />
        )} />
        <Controller control={control} name="privateNotes" render={({ field: { onChange, onBlur, value } }) => (
          <TextInput label="Private Notes" placeholder="Only visible to you" multiline numberOfLines={3} onChangeText={onChange} onBlur={onBlur} value={value} />
        )} />

        <Button
          label="Save Changes"
          onPress={handleSubmit(onSubmit)}
          loading={updateMutation.isPending}
          style={styles.submitBtn}
        />
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  center: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  scroll: {
    padding: Spacing.lg,
    paddingBottom: Spacing.xxl * 2,
  },
  submitBtn: {
    marginTop: Spacing.xl,
  },
  pickerWrapper: {
    marginBottom: Spacing.md,
  },
  label: {
    fontSize: FontSize.sm,
    fontWeight: FontWeight.medium,
    color: Colors.textPrimary,
    marginBottom: Spacing.xs,
  },
  picker: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: Colors.surface,
    borderWidth: 1,
    borderColor: Colors.border,
    borderRadius: BorderRadius.md,
    paddingHorizontal: Spacing.md,
    height: 48,
  },
  pickerText: {
    fontSize: FontSize.md,
    color: Colors.textPrimary,
  },
  pickerPlaceholder: {
    color: Colors.textMuted,
  },
  errorText: {
    color: Colors.danger,
    fontSize: FontSize.sm,
    marginTop: 4,
  },
  dropdown: {
    backgroundColor: Colors.surface,
    borderWidth: 1,
    borderColor: Colors.border,
    borderRadius: BorderRadius.md,
    marginTop: 4,
    maxHeight: 200,
  },
  dropdownItem: {
    padding: Spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  dropdownItemText: {
    fontSize: FontSize.md,
    color: Colors.textPrimary,
  },
});
