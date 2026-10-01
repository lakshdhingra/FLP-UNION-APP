import api from '../lib/api';
import type { RegisterManagerInput } from '../types/api.types';

export const authService = {
  login: (email: string, password: string) =>
    api.post('/auth/login', { email, password }).then(r => r.data),

  register: (data: RegisterManagerInput) =>
    api.post('/auth/register/manager', data).then(r => r.data),

  refresh: (refreshToken: string) =>
    api.post('/auth/refresh', { refreshToken }).then(r => r.data),

  logout: (refreshToken: string) =>
    api.post('/auth/logout', { refreshToken }).then(r => r.data),
};

export const statesService = {
  getAll: () => api.get('/states').then(r => r.data),
  getDistricts: (stateId: string) => api.get(`/states/${stateId}/districts`).then(r => r.data),
};

export const managerService = {
  getProfile: () => api.get('/manager/profile').then(r => r.data),
  updateProfile: (data: { fullName?: string; profilePhotoUrl?: string }) =>
    api.patch('/manager/profile', data).then(r => r.data),
  getDashboard: () => api.get('/manager/dashboard').then(r => r.data),

  // Engineer directory
  getEngineers: (params?: { search?: string; designation?: string; page?: number; limit?: number }) =>
    api.get('/manager/engineers', { params }).then(r => r.data),
  getEngineer: (id: string) => api.get(`/manager/engineers/${id}`).then(r => r.data),
  createEngineer: (data: Record<string, unknown>) =>
    api.post('/manager/engineers', data).then(r => r.data),
  updateEngineer: (id: string, data: Record<string, unknown>) =>
    api.patch(`/manager/engineers/${id}`, data).then(r => r.data),
  deleteEngineer: (id: string) =>
    api.delete(`/manager/engineers/${id}`).then(r => r.data),

  // Manager directory (same-state)
  getManagers: (params?: { search?: string; districtId?: string; page?: number; limit?: number }) =>
    api.get('/manager/managers', { params }).then(r => r.data),
  getManager: (id: string) => api.get(`/manager/managers/${id}`).then(r => r.data),
  getManagerEngineers: (id: string) =>
    api.get(`/manager/managers/${id}/engineers`).then(r => r.data),
};

export const issuesService = {
  create: (data: { type: string; title: string; description: string; attachmentUrl?: string }) =>
    api.post('/issues', data).then(r => r.data),
  getMine: () => api.get('/issues/mine').then(r => r.data),
  getOne: (id: string) => api.get(`/issues/${id}`).then(r => r.data),
};

export const adminService = {
  // Analytics
  getSummary: () => api.get('/admin/analytics/summary').then(r => r.data),
  // States
  getStates: (includeInactive = false) =>
    api.get('/admin/states', { params: { includeInactive } }).then(r => r.data),
  createState: (name: string) => api.post('/admin/states', { name }).then(r => r.data),
  updateState: (id: string, data: { name?: string; isActive?: boolean }) =>
    api.patch(`/admin/states/${id}`, data).then(r => r.data),
  // Districts
  getDistricts: (stateId?: string) =>
    api.get('/admin/districts', { params: { stateId } }).then(r => r.data),
  createDistrict: (name: string, stateId: string) =>
    api.post('/admin/districts', { name, stateId }).then(r => r.data),
  // Managers
  getManagers: (params?: Record<string, unknown>) =>
    api.get('/admin/managers', { params }).then(r => r.data),
  getManager: (id: string) => api.get(`/admin/managers/${id}`).then(r => r.data),
  // Engineers
  getEngineers: (params?: Record<string, unknown>) =>
    api.get('/admin/engineers', { params }).then(r => r.data),
  getEngineer: (id: string) => api.get(`/admin/engineers/${id}`).then(r => r.data),
  deleteEngineer: (id: string) => api.delete(`/admin/engineers/${id}`).then(r => r.data),
  // Issues
  getIssues: (params?: Record<string, unknown>) =>
    api.get('/admin/issues', { params }).then(r => r.data),
  updateIssueStatus: (id: string, status: string) =>
    api.patch(`/issues/${id}/status`, { status }).then(r => r.data),
  // Audit
  getAuditLogs: (params?: Record<string, unknown>) =>
    api.get('/admin/audit-logs', { params }).then(r => r.data),
};
