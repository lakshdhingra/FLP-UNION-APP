# AWS RDS PostgreSQL Schema & Migration Plan - FLP Union

This plan details how the existing PostgreSQL database schema will be mapped and deployed to **AWS RDS PostgreSQL**, guaranteeing zero data loss, exact schema fidelity, and minimal application downtime.

---

## 1. AWS RDS Infrastructure Specifications

### 1.1 Recommended Database Engine & Version
- **Engine**: AWS RDS for PostgreSQL
- **Recommended Version**: **PostgreSQL 16.3** (or latest 16.x LTS release)
- **Rationale**: 100% backward compatible with Supabase PostgreSQL (PostgreSQL 15/16), offers optimized query performance, JSONB performance improvements, and full support for native PostgreSQL text arrays (`TEXT[]`) and UUID generation.

### 1.2 Topology & Network Architecture
- **VPC Subnets**: Deploy in Private Database Subnets across 2 Availability Zones (Multi-AZ deployment for production high availability).
- **Security Groups**: Restrict inbound access on Port `5432` strictly to the Application Server Security Group (e.g. AWS ECS / EC2 backend service instance).
- **Connection Pooling**: Optional AWS RDS Proxy layer for managing application connection scaling.

---

## 2. Target AWS RDS Schema Specification

The target AWS RDS PostgreSQL database will receive a 1-to-1 deployment of all 10 existing Prisma tables, 4 Enums, 12 Foreign Key Constraints, and 23 Indexes.

### 2.1 Enums (Exact Match)
- `Role`: `('ADMIN', 'MANAGER')`
- `IssueType`: `('ISSUE', 'SUPPORT_REQUEST')`
- `IssueStatus`: `('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')`
- `NotificationType`: `('ISSUE_UPDATE', 'ANNOUNCEMENT', 'SYSTEM', 'MANAGER_MESSAGE')`

### 2.2 Table Mapping Summary

| Table Name | Primary Key | Total Columns | Foreign Keys | Unique Constraints | Indexes |
|---|---|---|---|---|---|
| `User` | `id` (UUID) | 8 | 0 | `email`, `mobile` | `User_email_idx`, `User_mobile_idx` |
| `RefreshToken` | `id` (UUID) | 8 | 1 (`userId`) | `tokenHash` | `RefreshToken_userId_idx`, `expiresAt_idx` |
| `State` | `id` (UUID) | 5 | 0 | `name` | None |
| `District` | `id` (UUID) | 6 | 1 (`stateId`) | `(stateId, name)` | `District_stateId_idx` |
| `ManagerProfile` | `id` (UUID) | 8 | 3 (`userId`, `stateId`, `districtId`) | `userId` | `districtId_idx`, `stateId_idx` |
| `Engineer` | `id` (UUID) | 19 | 3 (`stateId`, `districtId`, `managerId`)| `(managerId, phone)` | `managerId_idx`, `districtId_idx`, `stateId_idx`, `createdAt_idx` |
| `Issue` | `id` (UUID) | 10 | 1 (`reporterId`) | None | `reporterId_idx`, `status_idx`, `createdAt_idx` |
| `Announcement` | `id` (UUID) | 7 | 1 (`authorId`) | None | `Announcement_isActive_idx` |
| `Notification` | `id` (UUID) | 8 | 1 (`userId`) | None | `userId_idx`, `(userId, isRead)_idx` |
| `AuditLog` | `id` (UUID) | 7 | 1 (`actorId`) | None | `actorId_idx`, `(targetType, targetId)_idx`, `createdAt_idx` |

---

## 3. Step-by-Step Migration Execution Procedure

### Step 1: Provision AWS RDS Instance
1. Provision AWS RDS PostgreSQL 16.x instance in target AWS Region (e.g. `ap-south-1`).
2. Configure initial Master Username and Password.
3. Configure VPC Security Group rules to allow incoming connections on port 5432 from backend services or deployment host.

### Step 2: Configure Environment Connection Strings
Update NestJS environment configuration (`apps/api/.env`):
```env
# AWS RDS Connection Strings
DATABASE_URL="postgresql://<DB_USER>:<DB_PASSWORD>@<RDS_ENDPOINT>:5432/<DB_NAME>?schema=public&sslmode=require"
DIRECT_URL="postgresql://<DB_USER>:<DB_PASSWORD>@<RDS_ENDPOINT>:5432/<DB_NAME>?schema=public&sslmode=require"
```

### Step 3: Apply Database Migrations
Execute Prisma migration deployment against the target AWS RDS instance:
```bash
cd apps/api
npx prisma migrate deploy
```
This applies all DDL SQL scripts in chronological order (`20260902130807_init` and `20260902131025_full_schema`), creating all enums, tables, unique keys, indexes, and foreign key constraints without modifying schema definitions.

### Step 4: Seed Initial Reference Data
Populate all 36 Indian States/UTs, all districts, and the seed admin user:
```bash
cd apps/api
npx prisma db seed
```

### Step 5: Verification & Health Checks
Verify database deployment:
1. Execute `npx prisma studio` or run connectivity test suite.
2. Confirm 10 tables exist and all foreign key cascades perform as specified.
3. Validate API endpoints (`/api/states`, `/api/auth/login`, `/api/admin/analytics/summary`).

---

## 4. Constraint & Integrity Statement

- **Zero Schema Alteration**: The schema target on AWS RDS matches the source `schema.prisma` 100%.
- **Zero Application Code Changes Required**: The NestJS backend database layer (`PrismaService`) interacts with AWS RDS seamlessly via standard Prisma Client interfaces.
