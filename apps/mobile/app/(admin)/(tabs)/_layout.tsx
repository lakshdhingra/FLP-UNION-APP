import { Tabs } from 'expo-router';
import { LayoutDashboard, Users, Building2, HelpCircle } from 'lucide-react-native';
import { Colors, FontSize } from '../../../src/constants/theme';

export default function AdminTabLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: Colors.surface,
          borderTopColor: Colors.border,
          borderTopWidth: 1,
          height: 64,
          paddingBottom: 8,
          paddingTop: 6,
        },
        tabBarActiveTintColor: Colors.accent,
        tabBarInactiveTintColor: Colors.textMuted,
        tabBarLabelStyle: { fontSize: FontSize.xs, fontWeight: '500' },
      }}
    >
      <Tabs.Screen name="dashboard" options={{ title: 'Dashboard', tabBarIcon: ({ color, size }) => <LayoutDashboard size={size} color={color} /> }} />
      <Tabs.Screen name="managers" options={{ title: 'Managers', tabBarIcon: ({ color, size }) => <Users size={size} color={color} /> }} />
      <Tabs.Screen name="engineers" options={{ title: 'Engineers', tabBarIcon: ({ color, size }) => <Users size={size} color={color} /> }} />
      <Tabs.Screen name="issues" options={{ title: 'Issues', tabBarIcon: ({ color, size }) => <HelpCircle size={size} color={color} /> }} />
      <Tabs.Screen name="states" options={{ title: 'States', tabBarIcon: ({ color, size }) => <Building2 size={size} color={color} /> }} />
    </Tabs>
  );
}