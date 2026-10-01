import React, { useState } from 'react';
import {
  View, TextInput as RNTextInput, Text,
  TouchableOpacity, StyleSheet, TextInputProps,
} from 'react-native';
import { Eye, EyeOff } from 'lucide-react-native';
import { Colors, BorderRadius, FontSize, Spacing } from '../../constants/theme';

interface InputProps extends TextInputProps {
  label?: string;
  error?: string;
  isPassword?: boolean;
}

export function TextInput({ label, error, isPassword, style, value, ...props }: InputProps) {
  const [show, setShow] = useState(false);
  return (
    <View style={styles.wrapper}>
      {label && <Text style={styles.label}>{label}</Text>}
      <View style={[styles.inputRow, error ? styles.inputError : undefined]}>
        <RNTextInput
          style={[styles.input, style]}
          placeholderTextColor={Colors.textMuted}
          selectionColor={Colors.accent}
          secureTextEntry={isPassword && !show}
          value={value ?? ''}
          {...props}
        />
        {isPassword && (
          <TouchableOpacity onPress={() => setShow(v => !v)} style={styles.eyeBtn}>
            {show
              ? <EyeOff size={18} color={Colors.textMuted} />
              : <Eye size={18} color={Colors.textMuted} />
            }
          </TouchableOpacity>
        )}
      </View>
      {error && <Text style={styles.errorText}>{error}</Text>}
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: { marginBottom: Spacing.md },
  label: {
    fontSize: FontSize.sm,
    color: Colors.textSecondary,
    marginBottom: 6,
    fontWeight: '500',
  },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.card,
    borderRadius: BorderRadius.md,
    borderWidth: 1,
    borderColor: Colors.border,
    paddingHorizontal: Spacing.md,
  },
  inputError: { borderColor: Colors.danger },
  input: {
    flex: 1,
    height: 48,
    fontSize: FontSize.md,
    color: Colors.textPrimary,
  },
  eyeBtn: { padding: Spacing.xs },
  errorText: { fontSize: FontSize.xs, color: Colors.danger, marginTop: 4 },
});
