import { Stack } from 'expo-router';
import { Colors } from '../../../src/constants/theme';

export default function EngineerLayout() {
  return (
    <Stack
      screenOptions={{
        headerStyle: { backgroundColor: Colors.surface },
        headerTintColor: Colors.textPrimary,
        headerTitleStyle: { fontWeight: '600' },
      }}
    />
  );
}
