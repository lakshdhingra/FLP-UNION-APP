import { Stack, Redirect } from 'expo-router';
import { useAuthStore } from '../../src/store/auth.store';

export default function AuthLayout() {
  const { user, isLoading } = useAuthStore();
  if (!isLoading && user) {
    return <Redirect href={user.role === 'ADMIN' ? '/(admin)/(tabs)/dashboard' : '/(manager)/(tabs)/dashboard'} />;
  }
  return <Stack screenOptions={{ headerShown: false }} />;
}
