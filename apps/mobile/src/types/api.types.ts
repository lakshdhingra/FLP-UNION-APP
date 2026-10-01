export interface State { id: string; name: string; }
export interface District { id: string; name: string; stateId: string; }

export interface RegisterManagerInput {
  fullName: string;
  mobile: string;
  email: string;
  stateId: string;
  districtId: string;
  password: string;
  confirmPassword: string;
}

export interface Manager {
  id: string;
  fullName: string;
  profilePhotoUrl?: string;
  email: string;
  mobile: string;
  state: State;
  district: District;
  totalEngineers: number;
}

export interface Engineer {
  id: string;
  fullName: string;
  phone: string;
  email?: string;
  profilePhotoUrl?: string;
  address?: string;
  state: State;
  district: District;
  skills: string[];
  experienceYears?: number;
  designation?: string;
  govIdType?: string;
  govIdNumber?: string;
  salary?: number;
  privateNotes?: string;
  isActive: boolean;
  isOwned?: boolean;
  managerId?: string;
  manager?: { id: string; fullName: string };
  createdAt: string;
  updatedAt: string;
}

export interface Issue {
  id: string;
  type: 'ISSUE' | 'SUPPORT_REQUEST';
  title: string;
  description: string;
  status: 'OPEN' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED';
  attachmentUrl?: string;
  reporterId: string;
  createdAt: string;
}

export interface DashboardData {
  manager: Manager;
  stats: {
    totalEngineers: number;
    activeEngineers: number;
    inactiveEngineers: number;
    designationDistribution: Record<string, number>;
    experienceDistribution: Record<string, number>;
  };
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: { total: number; page: number; limit: number; totalPages?: number };
}
