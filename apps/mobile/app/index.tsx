import { useEffect } from 'react';
import { View, ActivityIndicator } from 'react-native';
import { router } from 'expo-router';
import { useAuthStore } from '../src/store/auth.store';
import { Colors } from '../src/constants/theme';

export default function Index() {
  const { isAuthenticated, isLoading, user } = useAuthStore();

  useEffect(() => {
    if (isLoading) return;
    if (!isAuthenticated) {
      router.replace('/(auth)/login');
    } else if (user?.role === 'ADMIN') {
      router.replace('/(admin)/(tabs)/dashboard');
    } else {
      router.replace('/(manager)/(tabs)/dashboard');
    }
  }, [isAuthenticated, isLoading, user]);

  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: Colors.background }}>
      <ActivityIndicator color={Colors.accent} size="large" />
    </View>
  );
}
