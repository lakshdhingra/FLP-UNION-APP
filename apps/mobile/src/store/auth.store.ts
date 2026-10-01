import { create } from 'zustand';
import axios from 'axios';
import { tokenStorage, setUnauthorizedHandler } from '../lib/api';
import api from '../lib/api';
import { router } from 'expo-router';

export type UserRole = 'ADMIN' | 'MANAGER';

export interface AuthUser {
  userId: string;
  role: UserRole;
  email?: string;
}

interface AuthState {
  user: AuthUser | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<UserRole>;
  logout: () => Promise<void>;
  hydrate: () => Promise<void>;
}

// Decode JWT payload without a library
function decodeJwt(token: string): Record<string, unknown> {
  try {
    const payload = token.split('.')[1];
    const decoded = atob(payload.replace(/-/g, '+').replace(/_/g, '/'));
    return JSON.parse(decoded);
  } catch {
    return {};
  }
}

export const useAuthStore = create<AuthState>((set, get) => {
  // Register handler so the API interceptor can call logout on 401
  setUnauthorizedHandler(async () => {
    await tokenStorage.clearTokens();
    set({ user: null, isAuthenticated: false });
    router.replace('/(auth)/login');
  });

  return {
    user: null,
    isAuthenticated: false,
    isLoading: true,

    hydrate: async () => {
      try {
        const token = await tokenStorage.getAccessToken();
        if (!token) { set({ isLoading: false }); return; }
        const payload = decodeJwt(token) as { sub?: string; userId?: string; role?: UserRole; exp?: number };
        const exp = payload.exp ?? 0;
        if (Date.now() / 1000 > exp) {
          // Try refresh
          const refreshToken = await tokenStorage.getRefreshToken();
          if (!refreshToken) { set({ isLoading: false }); return; }
          const res = await axios.post(`${process.env.EXPO_PUBLIC_API_URL ?? 'http://10.0.2.2:3000/api'}/auth/refresh`, { refreshToken });
          await tokenStorage.setTokens(res.data.accessToken, res.data.refreshToken);
          const newPayload = decodeJwt(res.data.accessToken) as { sub?: string; userId?: string; role?: UserRole };
          set({
            user: { userId: newPayload.sub ?? newPayload.userId ?? '', role: newPayload.role ?? 'MANAGER' },
            isAuthenticated: true,
            isLoading: false,
          });
        } else {
          set({
            user: { userId: payload.sub ?? payload.userId ?? '', role: payload.role ?? 'MANAGER' },
            isAuthenticated: true,
            isLoading: false,
          });
        }
      } catch {
        await tokenStorage.clearTokens();
        set({ user: null, isAuthenticated: false, isLoading: false });
      }
    },

    login: async (email: string, password: string) => {
      const res = await api.post('/auth/login', { email, password });
      const { accessToken, refreshToken } = res.data;
      await tokenStorage.setTokens(accessToken, refreshToken);
      const payload = decodeJwt(accessToken) as { sub?: string; userId?: string; role?: UserRole };
      const role = payload.role ?? 'MANAGER';
      set({
        user: { userId: payload.sub ?? payload.userId ?? '', role, email },
        isAuthenticated: true,
      });
      return role;
    },

    logout: async () => {
      try {
        const refreshToken = await tokenStorage.getRefreshToken();
        if (refreshToken) await api.post('/auth/logout', { refreshToken });
      } catch { /* best effort */ }
      await tokenStorage.clearTokens();
      set({ user: null, isAuthenticated: false });
      router.replace('/(auth)/login');
    },
  };
});
