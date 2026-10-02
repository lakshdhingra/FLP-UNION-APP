# Database Audit Report - FLP Union Platform

This audit documents the exact database structure, configuration, schema definitions, and migration files present in the repository.

---

## 1. Database Engine
- **Engine**: PostgreSQL (Compatibility with PostgreSQL 14 / 15 / 16)
- **ORM / Client**: Prisma ORM (`@prisma/client` v5.22.0)
- **Current Hosting Configuration**: Supabase PostgreSQL (referenced via connection strings in environment configurations)

---

## 2. Enums
Defined in `schema.prisma` and created via `CREATE TYPE` in migration SQL:

### `Role`
- `ADMIN`
- `MANAGER`

### `IssueType`
- `ISSUE`
- `SUPPORT_REQUEST`

### `IssueStatus`
- `OPEN`
- `IN_PROGRESS`
- `RESOLVED`
- `CLOSED`

### `NotificationType`
- `ISSUE_UPDATE`
- `ANNOUNCEMENT`
- `SYSTEM`
- `MANAGER_MESSAGE`

---

## 3. Tables & Complete Column Specifications

Total Tables: **10**

### 3.1 `User`
Core identity table storing login credentials and basic account info for Admins & Managers.

| Column | Data Type | Nullable | Default Value | Constraints / Notes |
|---|---|---|---|---|
| `id` | `TEXT` / `UUID` | No | `uuid()` | Primary Key (`User_pkey`) |
| `email` | `TEXT` | No | None | `UNIQUE`, Indexed (`User_email_idx`) |
| `mobile` | `TEXT` | No | None | `UNIQUE`, Indexed (`User_mobile_idx`) |
| `passwordHash` | `TEXT` | No | None | Argon2 hash string |
| `role` | `Role` (ENUM) | No | None | Enforces `Role` enum ('ADMIN', 'MANAGER') |
| `isActive` | `BOOLEAN` | No | `true` | Account active flag |
| `createdAt` | `TIMESTAMP(3)` | No | `CURRENT_TIMESTAMP` | System creation timestamp |
| `updatedAt` | `TIMESTAMP(3)` | No | None | Managed auto-update timestamp |

---

### 3.2 `RefreshToken`
Stores session refresh tokens for token rotation and security revocation.

| Column | Data Type | Nullable | Default Value | Constraints / Notes |
|---|---|---|---|---|
| `id` | `TEXT` / `UUID` | No | `uuid()` | Primary Key (`RefreshToken_pkey`) |
| `userId` | `TEXT` | No | None | Foreign Key -> `User(id)` (`ON DELETE CASCADE`) |
| `tokenHash` | `TEXT` | No | None | `UNIQUE` |
| `expiresAt` | `TIMESTAMP(3)` | No | None | Expiration time, Indexed |
| `revokedAt` | `TIMESTAMP(3)` | Yes | `NULL` | Revocation timestamp |
| `replacedByHash` | `TEXT` | Yes | `NULL` | Token family rotation link |
| `createdByIp` | `TEXT` | Yes | `NULL` | IP address at login |
| `createdAt` | `TIMESTAMP(3)` | No | `CURRENT_TIMESTAMP` | Creation timestamp |

---

### 3.3 `State`
Administrative states / regions master table.

| Column | Data Type | Nullable | Default Value | Constraints / Notes |
|---|---|---|---|---|
| `id` | `TEXT` / `UUID` | No | `uuid()` | Primary Key (`State_pkey`) |
| `name` | `TEXT` | No | None | `UNIQUE` (`State_name_key`) |
| `isActive` | `BOOLEAN` | No | `true` | Active status flag |
| `createdAt` | `TIMESTAMP(3)` | No | `CURRENT_TIMESTAMP` | Creation timestamp |
| `updatedAt` | `TIMESTAMP(3)` | No | None | Managed auto-update timestamp |

---

### 3.4 `District`
Districts associated with a specific State.

| Column | Data Type | Nullable | Default Value | Constraints / Notes |
|---|---|---|---|---|
| `id` | `TEXT` / `UUID` | No | `uuid()` | Primary Key (`District_pkey`) |
| `name` | `TEXT` | No | None | District name |
| `stateId` | `TEXT` | No | None | Foreign Key -> `State(id)` (`ON DELETE RESTRICT`) |
| `isActive` | `BOOLEAN` | No | `true` | Active status flag |
| `createdAt` | `TIMESTAMP(3)` | No | `CURRENT_TIMESTAMP` | Creation timestamp |
| `updatedAt` | `TIMESTAMP(3)` | No | None | Managed auto-update timestamp |

- **Unique Constraint**: `@@unique([stateId, name])` (`District_stateId_name_key`)
- **Index**: `@@index([stateId])` (`District_stateId_idx`)

---

### 3.5 `ManagerProfile`
Manager organizational profiles linked 1-to-1 with `User`.

| Column | Data Type | Nullable | Default Value | Constraints / Notes |
|---|---|---|---|---|
| `id` | `TEXT` / `UUID` | No | `uuid()` | Primary Key (`ManagerProfile_pkey`) |
| `userId` | `TEXT` | No | None | `UNIQUE` Foreign Key -> `User(id)` (`ON DELETE CASCADE`) |
| `fullName` | `TEXT` | No | None | Full legal name |
| `profilePhotoUrl` | `TEXT` | Yes | `NULL` | Image media URL column |
| `stateId` | `TEXT` | No | None | Foreign Key -> `State(id)` (`ON DELETE RESTRICT`) |
| `districtId` | `TEXT` | No | None | Foreign Key -> `District(id)` (`ON DELETE RESTRICT`) |
| `createdAt` | `TIMESTAMP(3)` | No | `CURRENT_TIMESTAMP` | Creation timestamp |
| `updatedAt` | `TIMESTAMP(3)` | No | None | Managed auto-update timestamp |

- **Indexes**: `@@index([districtId])`, `@@index([stateId])`

---

### 3.6 `Engineer`
Service technicians and workforce records under manager supervision.

| Column | Data Type | Nullable | Default Value | Constraints / Notes |
|---|---|---|---|---|
| `id` | `TEXT` / `UUID` | No | `uuid()` | Primary Key (`Engineer_pkey`) |
| `fullName` | `TEXT` | No | None | Full name |
| `phone` | `TEXT` | No | None | Phone number |
| `email` | `TEXT` | Yes | `NULL` | Optional email |
| `profilePhotoUrl` | `TEXT` | Yes | `NULL` | Image media URL column |
| `address` | `TEXT` | Yes | `NULL` | Physical address |
| `stateId` | `TEXT` | No | None | Foreign Key -> `State(id)` (`ON DELETE RESTRICT`) |
| `districtId` | `TEXT` | No | None | Foreign Key -> `District(id)` (`ON DELETE RESTRICT`) |
| `skills` | `TEXT[]` (Array) | No | `[]` | PostgreSQL text array for skills |
| `experienceYears` | `DECIMAL(4,1)` | Yes | `NULL` | Numeric experience years |
| `designation` | `TEXT` | Yes | `NULL` | Job designation |
| `govIdType` | `TEXT` | Yes | `NULL` | Government ID type (Aadhaar/PAN/etc) |
| `govIdNumber` | `TEXT` | Yes | `NULL` | Government ID number |
| `salary` | `DECIMAL(12,2)` | Yes | `NULL` | Monthly salary / earnings |
| `privateNotes` | `TEXT` | Yes | `NULL` | Manager internal notes |
| `managerId` | `TEXT` | No | None | Foreign Key -> `ManagerProfile(id)` (`ON DELETE CASCADE`) |
| `isActive` | `BOOLEAN` | No | `true` | Active status flag |
| `createdAt` | `TIMESTAMP(3)` | No | `CURRENT_TIMESTAMP` | Creation timestamp |
| `updatedAt` | `TIMESTAMP(3)` | No | None | Managed auto-update timestamp |

- **Unique Constraint**: `@@unique([managerId, phone])`
- **Indexes**: `@@index([managerId])`, `@@index([districtId])`, `@@index([stateId])`, `@@index([createdAt])`

---

### 3.7 `Issue`
Technical issues and support requests filed by users.

| Column | Data Type | Nullable | Default Value | Constraints / Notes |
|---|---|---|---|---|
| `id` | `TEXT` / `UUID` | No | `uuid()` | Primary Key (`Issue_pkey`) |
| `type` | `IssueType` (ENUM) | No | `'ISSUE'` | Enforces `IssueType` ('ISSUE', 'SUPPORT_REQUEST') |
| `title` | `TEXT` | No | None | Summary title |
| `description` | `TEXT` | No | None | Full description text |
| `status` | `IssueStatus` (ENUM)| No | `'OPEN'` | Enforces `IssueStatus` ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED') |
| `attachmentUrl` | `TEXT` | Yes | `NULL` | Document / screenshot media URL column |
| `reporterId` | `TEXT` | No | None | Foreign Key -> `User(id)` (`ON DELETE CASCADE`) |
| `createdAt` | `TIMESTAMP(3)` | No | `CURRENT_TIMESTAMP` | Creation timestamp |
| `updatedAt` | `TIMESTAMP(3)` | No | None | Managed auto-update timestamp |
| `resolvedAt` | `TIMESTAMP(3)` | Yes | `NULL` | Resolution timestamp |

- **Indexes**: `@@index([reporterId])`, `@@index([status])`, `@@index([createdAt])`

---

### 3.8 `Announcement`
Broadcast announcements issued by Admins to Managers.

| Column | Data Type | Nullable | Default Value | Constraints / Notes |
|---|---|---|---|---|
| `id` | `TEXT` / `UUID` | No | `uuid()` | Primary Key (`Announcement_pkey`) |
| `title` | `TEXT` | No | None | Title |
| `body` | `TEXT` | No | None | Announcement body text |
| `isActive` | `BOOLEAN` | No | `true` | Visibility flag |
| `authorId` | `TEXT` | No | None | Foreign Key -> `User(id)` (`ON DELETE RESTRICT`) |
| `createdAt` | `TIMESTAMP(3)` | No | `CURRENT_TIMESTAMP` | Creation timestamp |
| `updatedAt` | `TIMESTAMP(3)` | No | None | Managed auto-update timestamp |

- **Index**: `@@index([isActive])`

---

### 3.9 `Notification`
User notifications generated by system events.

| Column | Data Type | Nullable | Default Value | Constraints / Notes |
|---|---|---|---|---|
| `id` | `TEXT` / `UUID` | No | `uuid()` | Primary Key (`Notification_pkey`) |
| `userId` | `TEXT` | No | None | Foreign Key -> `User(id)` (`ON DELETE CASCADE`) |
| `type` | `NotificationType` (ENUM)| No | None | Enforces `NotificationType` |
| `title` | `TEXT` | No | None | Notification heading |
| `body` | `TEXT` | No | None | Content text |
| `data` | `JSONB` | Yes | `NULL` | Flexible payload metadata |
| `isRead` | `BOOLEAN` | No | `false` | Read status |
| `createdAt` | `TIMESTAMP(3)` | No | `CURRENT_TIMESTAMP` | Creation timestamp |

- **Indexes**: `@@index([userId])`, `@@index([userId, isRead])`

---

### 3.10 `AuditLog`
Security and administrative action trail logging.

| Column | Data Type | Nullable | Default Value | Constraints / Notes |
|---|---|---|---|---|
| `id` | `TEXT` / `UUID` | No | `uuid()` | Primary Key (`AuditLog_pkey`) |
| `actorId` | `TEXT` | Yes | `NULL` | Foreign Key -> `User(id)` (`ON DELETE SET NULL`) |
| `action` | `TEXT` | No | None | Action name string (e.g. `CREATE_ENGINEER`) |
| `targetType` | `TEXT` | No | None | Entity type (e.g. `Engineer`, `State`) |
| `targetId` | `TEXT` | Yes | `NULL` | ID of target entity |
| `metadata` | `JSONB` | Yes | `NULL` | Action snapshot details |
| `createdAt` | `TIMESTAMP(3)` | No | `CURRENT_TIMESTAMP` | Log timestamp |

- **Indexes**: `@@index([actorId])`, `@@index([targetType, targetId])`, `@@index([createdAt])`

---

## 4. Summary of Table Relationships & Foreign Keys

Total Relationships: **12**

1. `RefreshToken.userId` -> `User.id` (`ON DELETE CASCADE`, `ON UPDATE CASCADE`)
2. `District.stateId` -> `State.id` (`ON DELETE RESTRICT`, `ON UPDATE CASCADE`)
3. `ManagerProfile.userId` -> `User.id` (`ON DELETE CASCADE`, `ON UPDATE CASCADE`) [1-to-1 Strict]
4. `ManagerProfile.stateId` -> `State.id` (`ON DELETE RESTRICT`, `ON UPDATE CASCADE`)
5. `ManagerProfile.districtId` -> `District.id` (`ON DELETE RESTRICT`, `ON UPDATE CASCADE`)
6. `Engineer.stateId` -> `State.id` (`ON DELETE RESTRICT`, `ON UPDATE CASCADE`)
7. `Engineer.districtId` -> `District.id` (`ON DELETE RESTRICT`, `ON UPDATE CASCADE`)
8. `Engineer.managerId` -> `ManagerProfile.id` (`ON DELETE CASCADE`, `ON UPDATE CASCADE`)
9. `Issue.reporterId` -> `User.id` (`ON DELETE CASCADE`, `ON UPDATE CASCADE`)
10. `Announcement.authorId` -> `User.id` (`ON DELETE RESTRICT`, `ON UPDATE CASCADE`)
11. `Notification.userId` -> `User.id` (`ON DELETE CASCADE`, `ON UPDATE CASCADE`)
12. `AuditLog.actorId` -> `User.id` (`ON DELETE SET NULL`, `ON UPDATE CASCADE`)

---

## 5. Specialized Database Features & Components

- **Views**: None present.
- **Stored Functions / Procedures**: None present.
- **Triggers**: None present.
- **Row-Level Security (RLS) Policies**: None present in Prisma migration SQL. Security and authorization are enforced at application level via NestJS Guards (`JwtAuthGuard`, `RolesGuard`).
- **Supabase Auth Dependencies**: None in backend codebase. (Auth uses Argon2 password hashing + NestJS JWT + custom `RefreshToken` table).
- **Supabase Storage Dependencies**: None directly in backend code. Files are referenced via URL strings (`profilePhotoUrl`, `attachmentUrl`).
- **Image / Document Columns**:
  - `ManagerProfile.profilePhotoUrl`
  - `Engineer.profilePhotoUrl`
  - `Issue.attachmentUrl`
- **Seed / Reference Data**: Included in `apps/api/prisma/seed.ts`. Seed script inserts 28 Indian States and 8 Union Territories with all their districts, plus standard seed Admin user (`admin@example.com`).
- **Domain Specific Entity Audit**:
  - `members` / `sub-members`: UNKNOWN / NOT PRESENT in current schema (Represented by `ManagerProfile` and `Engineer`).
  - `admins`: Represented by `User` with `role = 'ADMIN'`.
  - `managers`: Represented by `User` (`role = 'MANAGER'`) and linked `ManagerProfile`.
  - `engineers`: Represented by `Engineer` model.
  - `states` & `districts`: Present in `State` and `District` tables.
  - `issues`: Present in `Issue` table.
  - `applications`: UNKNOWN / NOT PRESENT.
  - `audit logs`: Present in `AuditLog` table.
  - `news` / `announcements`: Present in `Announcement` table.
  - `resources` / `media`: UNKNOWN / NOT PRESENT (stored as URL strings).
  - `leadership`: UNKNOWN / NOT PRESENT.
  - `contact messages`: UNKNOWN / NOT PRESENT.

---

## 6. Database Access in Backend Code

- **ORM Client**: Prisma ORM (`@prisma/client`) initialized via `PrismaService` (`apps/api/src/prisma/prisma.service.ts`).
- **Access Pattern**: All database interactions use standard Prisma API queries (`findMany`, `findUnique`, `create`, `update`, `upsert`, `delete`).
- **Raw SQL Queries**: Zero (`$queryRaw` and `$executeRaw` are not used anywhere in `apps/api/src`).

---

## 7. Database Environment Variables

Defined in `apps/api/.env.example`:
- `DATABASE_URL`: Connection string for Prisma ORM (`postgresql://...`).
- `DIRECT_URL`: Direct connection string for Prisma migrations (`postgresql://...`).

---

## MIGRATION RISKS

1. **Connection Pooling & PgBouncer Configuration**:
   Supabase provides built-in PgBouncer pooling via port 6543 / transaction mode. Standard AWS RDS PostgreSQL instances do not include a transaction pooler out of the box. Without AWS RDS Proxy or PgBouncer configured, high concurrent connection counts from NestJS microservices could exhaust PostgreSQL connection limits (`max_connections`).

2. **Direct Connection for Migrations**:
   Prisma requires a direct TCP connection (`DIRECT_URL`) to execute schema DDL migrations (`prisma migrate deploy`). If RDS is configured inside a private VPC subnet without public IP access, developer/CI runner machines will require VPN or Bastion host access to run migrations.

3. **Array Data Types (`TEXT[]`)**:
   `Engineer.skills` uses native PostgreSQL text arrays (`TEXT[]`). Ensure the target AWS RDS engine and configuration preserve standard PostgreSQL array handling.

4. **Timezone & Timestamp Precision**:
   All datetime columns use `TIMESTAMP(3)` (millisecond precision). Ensure the AWS RDS default timezone is set to `UTC` to avoid subtle timestamp drift across microservices.

5. **Legacy Supabase Environment Variables Cleanup**:
   `.env.example` contains unused legacy placeholders (`SUPABASE_URL`, `SUPABASE_ANON_KEY`). These must be sanitized to prevent configuration confusion post-migration.

---
