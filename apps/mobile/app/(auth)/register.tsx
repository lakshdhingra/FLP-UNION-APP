import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView,
  KeyboardAvoidingView, Platform, Alert,
} from 'react-native';
import { router, Link } from 'expo-router';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useStates, useDistricts } from '../../src/hooks/useApi';
import { authService } from '../../src/services/api.service';
import { Button } from '../../src/components/ui/Button';
import { TextInput } from '../../src/components/ui/TextInput';
import { Colors, FontSize, FontWeight, Spacing, BorderRadius, BorderRadius as BR } from '../../src/constants/theme';
import { TouchableOpacity } from 'react-native';
import { ChevronDown } from 'lucide-react-native';

const schema = z.object({
  fullName: z.string().min(2, 'Full name required'),
  mobile: z.string().regex(/^\+?[0-9]{7,15}$/, 'Enter a valid phone number'),
  email: z.string().email('Enter a valid email'),
  stateId: z.string().uuid('Select a state'),
  districtId: z.string().uuid('Select a district'),
  password: z.string().min(8).regex(/(?=.*[A-Za-z])(?=.*\d)/, 'Must contain a letter and number'),
  confirmPassword: z.string(),
}).refine(d => d.password === d.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
});
type FormData = z.infer<typeof schema>;

export default function RegisterScreen() {
  const [loading, setLoading] = useState(false);
  const [statePickerOpen, setStatePickerOpen] = useState(false);
  const [districtPickerOpen, setDistrictPickerOpen] = useState(false);
  const [selectedStateName, setSelectedStateName] = useState('');
  const [selectedDistrictName, setSelectedDistrictName] = useState('');

  const { data: states = [], isLoading: loadingStates, isError: errorStates } = useStates();
  const { control, handleSubmit, watch, setValue, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });
  const stateId = watch('stateId');
  const { data: districts = [], isLoading: loadingDistricts, isError: errorDistricts } = useDistricts(stateId);

  const onSubmit = async (data: FormData) => {
    setLoading(true);
    try {
      await authService.register(data);
      Alert.alert('Success', 'Account created! Please log in.', [
        { text: 'OK', onPress: () => router.replace('/(auth)/login') },
      ]);
    } catch (err: any) {
      const msg = err?.response?.data?.message ?? 'Registration failed.';
      Alert.alert('Error', Array.isArray(msg) ? msg.join('\n') : msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView style={{ flex: 1, backgroundColor: Colors.background }}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView contentContainerStyle={styles.container} keyboardShouldPersistTaps="handled">
        <View style={styles.header}>
          <Text style={styles.title}>Create Account</Text>
          <Text style={styles.subtitle}>Join TASPU as a Manager</Text>
        </View>

        <View style={styles.form}>
          <Controller control={control} name="fullName" render={({ field: { onChange, onBlur, value } }) => (
            <TextInput label="Full Name" placeholder="Your full name" onChangeText={onChange} onBlur={onBlur} value={value} error={errors.fullName?.message} />
          )} />
          <Controller control={control} name="mobile" render={({ field: { onChange, onBlur, value } }) => (
            <TextInput label="Mobile Number" placeholder="+91 9999999999" keyboardType="phone-pad" onChangeText={onChange} onBlur={onBlur} value={value} error={errors.mobile?.message} />
          )} />
          <Controller control={control} name="email" render={({ field: { onChange, onBlur, value } }) => (
            <TextInput label="Email Address" placeholder="you@example.com" keyboardType="email-address" autoCapitalize="none" onChangeText={onChange} onBlur={onBlur} value={value} error={errors.email?.message} />
          )} />

          {/* State Picker */}
          <View style={styles.pickerWrapper}>
            <Text style={styles.label}>State</Text>
            <TouchableOpacity style={styles.picker} onPress={() => setStatePickerOpen(!statePickerOpen)}>
              <Text style={[styles.pickerText, !selectedStateName && styles.pickerPlaceholder]}>
                {loadingStates ? 'Loading states...' : errorStates ? 'Failed to load' : (selectedStateName || 'Select State')}
              </Text>
              <ChevronDown size={18} color={Colors.textMuted} />
            </TouchableOpacity>
            {errors.stateId && <Text style={styles.errorText}>{errors.stateId.message}</Text>}
            {statePickerOpen && (
              <View style={styles.dropdown}>
                {states.map((s: any) => (
                  <TouchableOpacity key={s.id} style={styles.dropdownItem} onPress={() => {
                    setValue('stateId', s.id, { shouldValidate: true });
                    setValue('districtId', '', { shouldValidate: true });
                    setSelectedStateName(s.name);
                    setSelectedDistrictName('');
                    setStatePickerOpen(false);
                  }}>
                    <Text style={styles.dropdownText}>{s.name}</Text>
                  </TouchableOpacity>
                ))}
              </View>
            )}
          </View>

          {/* District Picker */}
          <View style={styles.pickerWrapper}>
            <Text style={styles.label}>District</Text>
            <TouchableOpacity style={[styles.picker, !stateId && styles.pickerDisabled]}
              onPress={() => stateId && setDistrictPickerOpen(!districtPickerOpen)}>
              <Text style={[styles.pickerText, !selectedDistrictName && styles.pickerPlaceholder]}>
                {loadingDistricts ? 'Loading districts...' : errorDistricts ? 'Failed to load' : (selectedDistrictName || (stateId ? 'Select District' : 'Select State first'))}
              </Text>
              <ChevronDown size={18} color={Colors.textMuted} />
            </TouchableOpacity>
            {errors.districtId && <Text style={styles.errorText}>{errors.districtId.message}</Text>}
            {districtPickerOpen && (
              <View style={styles.dropdown}>
                {districts.map((d: any) => (
                  <TouchableOpacity key={d.id} style={styles.dropdownItem} onPress={() => {
                    setValue('districtId', d.id, { shouldValidate: true });
                    setSelectedDistrictName(d.name);
                    setDistrictPickerOpen(false);
                  }}>
                    <Text style={styles.dropdownText}>{d.name}</Text>
                  </TouchableOpacity>
                ))}
              </View>
            )}
          </View>

          <Controller control={control} name="password" render={({ field: { onChange, onBlur, value } }) => (
            <TextInput label="Password" placeholder="Min 8 chars, letter + number" isPassword onChangeText={onChange} onBlur={onBlur} value={value} error={errors.password?.message} />
          )} />
          <Controller control={control} name="confirmPassword" render={({ field: { onChange, onBlur, value } }) => (
            <TextInput label="Confirm Password" placeholder="Repeat your password" isPassword onChangeText={onChange} onBlur={onBlur} value={value} error={errors.confirmPassword?.message} />
          )} />

          <Button label="Create Account" onPress={handleSubmit(onSubmit)} loading={loading} style={{ marginTop: Spacing.sm }} />

          <View style={styles.loginRow}>
            <Text style={styles.loginText}>Already have an account? </Text>
            <Link href="/(auth)/login" style={styles.loginLink}>Sign in</Link>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flexGrow: 1, padding: Spacing.lg },
  header: { alignItems: 'center', marginBottom: Spacing.xl, paddingTop: Spacing.xl },
  title: { fontSize: FontSize.xxxl, fontWeight: FontWeight.bold, color: Colors.textPrimary },
  subtitle: { fontSize: FontSize.md, color: Colors.textSecondary, marginTop: 4 },
  form: { backgroundColor: Colors.card, borderRadius: BorderRadius.xl, padding: Spacing.lg, borderWidth: 1, borderColor: Colors.border },
  label: { fontSize: FontSize.sm, color: Colors.textSecondary, marginBottom: 6, fontWeight: '500' },
  pickerWrapper: { marginBottom: Spacing.md },
  picker: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', backgroundColor: Colors.surface, borderRadius: BorderRadius.md, borderWidth: 1, borderColor: Colors.border, paddingHorizontal: Spacing.md, height: 48 },
  pickerDisabled: { opacity: 0.5 },
  pickerText: { color: Colors.textPrimary, fontSize: FontSize.md, flex: 1 },
  pickerPlaceholder: { color: Colors.textMuted },
  dropdown: { backgroundColor: Colors.surface, borderRadius: BorderRadius.md, borderWidth: 1, borderColor: Colors.border, marginTop: 4, overflow: 'hidden', zIndex: 100, elevation: 10 },
  dropdownItem: { paddingHorizontal: Spacing.md, paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: Colors.border },
  dropdownText: { color: Colors.textPrimary, fontSize: FontSize.md },
  errorText: { fontSize: 11, color: Colors.danger, marginTop: 4 },
  loginRow: { flexDirection: 'row', justifyContent: 'center', marginTop: Spacing.md },
  loginText: { fontSize: FontSize.sm, color: Colors.textSecondary },
  loginLink: { fontSize: FontSize.sm, color: Colors.accent, fontWeight: FontWeight.semibold },
});
