import { Stack } from 'expo-router';
import { Colors } from '../../../src/constants/theme';
export default function ManagerProfileLayout() {
  return <Stack screenOptions={{ headerStyle: { backgroundColor: Colors.surface }, headerTintColor: Colors.textPrimary, headerTitleStyle: { fontWeight: '600' } }} />;
}