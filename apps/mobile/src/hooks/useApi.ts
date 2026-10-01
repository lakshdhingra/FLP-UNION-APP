import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { managerService, statesService, issuesService } from '../services/api.service';

// ─── States & Districts ────────────────────────────────────────────────────
export const useStates = () =>
  useQuery({ queryKey: ['states'], queryFn: statesService.getAll, staleTime: 10 * 60 * 1000 });

export const useDistricts = (stateId?: string) =>
  useQuery({
    queryKey: ['districts', stateId],
    queryFn: () => statesService.getDistricts(stateId!),
    enabled: !!stateId,
    staleTime: 10 * 60 * 1000,
  });

// ─── Manager Profile & Dashboard ─────────────────────────────────────────
export const useManagerProfile = () =>
  useQuery({ queryKey: ['manager', 'profile'], queryFn: managerService.getProfile, staleTime: 5 * 60 * 1000 });

export const useManagerDashboard = () =>
  useQuery({ queryKey: ['manager', 'dashboard'], queryFn: managerService.getDashboard, staleTime: 2 * 60 * 1000 });

export const useUpdateProfile = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: managerService.updateProfile,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['manager', 'profile'] });
      qc.invalidateQueries({ queryKey: ['manager', 'dashboard'] });
    },
  });
};

// ─── Engineers ────────────────────────────────────────────────────────────
export const useMyEngineers = (params?: { search?: string; designation?: string; page?: number; limit?: number }) =>
  useQuery({
    queryKey: ['engineers', 'mine', params],
    queryFn: () => managerService.getEngineers(params),
    staleTime: 2 * 60 * 1000,
  });

export const useEngineer = (id?: string) =>
  useQuery({
    queryKey: ['engineer', id],
    queryFn: () => managerService.getEngineer(id!),
    enabled: !!id,
    staleTime: 5 * 60 * 1000,
  });

export const useCreateEngineer = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: managerService.createEngineer,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['engineers', 'mine'] });
      qc.invalidateQueries({ queryKey: ['manager', 'dashboard'] });
    },
  });
};

export const useUpdateEngineer = (id: string) => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Record<string, unknown>) => managerService.updateEngineer(id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['engineers', 'mine'] });
      qc.invalidateQueries({ queryKey: ['engineer', id] });
    },
  });
};

export const useDeleteEngineer = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: managerService.deleteEngineer,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['engineers', 'mine'] });
      qc.invalidateQueries({ queryKey: ['manager', 'dashboard'] });
    },
  });
};

// ─── Manager Directory (same-state) ──────────────────────────────────────
export const useSameStateManagers = (params?: { search?: string; districtId?: string; page?: number }) =>
  useQuery({
    queryKey: ['managers', 'directory', params],
    queryFn: () => managerService.getManagers(params),
    staleTime: 5 * 60 * 1000,
  });

export const useManagerProfileById = (id?: string) =>
  useQuery({
    queryKey: ['manager', 'other', id],
    queryFn: () => managerService.getManager(id!),
    enabled: !!id,
    staleTime: 5 * 60 * 1000,
  });

export const useManagerEngineers = (managerId?: string) =>
  useQuery({
    queryKey: ['manager', 'engineers', managerId],
    queryFn: () => managerService.getManagerEngineers(managerId!),
    enabled: !!managerId,
    staleTime: 5 * 60 * 1000,
  });

// ─── Issues ───────────────────────────────────────────────────────────────
export const useMyIssues = () =>
  useQuery({ queryKey: ['issues', 'mine'], queryFn: issuesService.getMine, staleTime: 2 * 60 * 1000 });

export const useCreateIssue = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: issuesService.create,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['issues', 'mine'] }),
  });
};
