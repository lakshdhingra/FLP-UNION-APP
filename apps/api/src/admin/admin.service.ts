import { BadRequestException } from '@nestjs/common';
import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { IssueStatus } from '@prisma/client';
import { CreateStateDto, UpdateStateDto, CreateDistrictDto, UpdateDistrictDto, AdminUpdateEngineerDto } from './dto/admin.dto';

import { AuditService } from '../audit/audit.service';
import { S3Service } from '../s3/s3.service';

@Injectable()
export class AdminService {
    constructor(
        private prisma: PrismaService,
        private audit: AuditService,
        private s3Service: S3Service,
    ) {}

    // ─── States ───────────────────────────────────────────────────────────

    async createState(actorId: string, dto: CreateStateDto) {
        try {
            const state = await this.prisma.state.create({ data: { name: dto.name } });
            this.audit.log({ actorId, action: 'CREATE', targetType: 'STATE', targetId: state.id, metadata: dto as any });
            return state;
        } catch (e: any) {
            if (e.code === 'P2002') throw new ConflictException('State name already exists');
            throw e;
        }
    }

    async findAllStates(includeInactive = false) {
        return this.prisma.state.findMany({
            where: includeInactive ? {} : { isActive: true },
            orderBy: { name: 'asc' },
            include: { _count: { select: { districts: true, managerProfiles: true, engineers: true } } },
        });
    }

    async updateState(actorId: string, id: string, dto: UpdateStateDto) {
        try {
            const state = await this.prisma.state.update({ where: { id }, data: dto });
            this.audit.log({ actorId, action: 'UPDATE', targetType: 'STATE', targetId: id, metadata: dto as any });
            return state;
        } catch (e: any) {
            if (e.code === 'P2025') throw new NotFoundException('State not found');
            throw e;
        }
    }

    // ─── Districts ────────────────────────────────────────────────────────

    async createDistrict(actorId: string, dto: CreateDistrictDto) {
        const state = await this.prisma.state.findUnique({ where: { id: dto.stateId } });
        if (!state) throw new NotFoundException('State not found');
        try {
            const district = await this.prisma.district.create({ data: { name: dto.name, stateId: dto.stateId } });
            this.audit.log({ actorId, action: 'CREATE', targetType: 'DISTRICT', targetId: district.id, metadata: dto as any });
            return district;
        } catch (e: any) {
            if (e.code === 'P2002') throw new ConflictException('District name already exists in this state');
            throw e;
        }
    }

    async findAllDistricts(stateId?: string) {
        return this.prisma.district.findMany({
            where: stateId ? { stateId } : {},
            orderBy: { name: 'asc' },
            include: {
                state: { select: { name: true } },
                _count: { select: { managerProfiles: true, engineers: true } },
            },
        });
    }

    async updateDistrict(actorId: string, id: string, dto: UpdateDistrictDto) {
        try {
            const district = await this.prisma.district.update({ where: { id }, data: dto });
            this.audit.log({ actorId, action: 'UPDATE', targetType: 'DISTRICT', targetId: id, metadata: dto as any });
            return district;
        } catch (e: any) {
            if (e.code === 'P2025') throw new NotFoundException('District not found');
            throw e;
        }
    }

    // ─── Managers ─────────────────────────────────────────────────────────

    async findAllManagers(opts: { stateId?: string; search?: string; page?: number; limit?: number }) {
        const page = opts.page ?? 1;
        const limit = Math.min(opts.limit ?? 20, 100);
        const where: any = {
            ...(opts.stateId ? { stateId: opts.stateId } : {}),
            ...(opts.search ? { fullName: { contains: opts.search, mode: 'insensitive' } } : {}),
        };
        const [data, total] = await Promise.all([
            this.prisma.managerProfile.findMany({
                where,
                skip: (page - 1) * limit,
                take: limit,
                orderBy: { fullName: 'asc' },
                include: {
                    state: { select: { id: true, name: true } },
                    district: { select: { id: true, name: true } },
                    user: { select: { id: true, email: true, mobile: true, createdAt: true } },
                    _count: { select: { engineers: true } },
                },
            }),
            this.prisma.managerProfile.count({ where }),
        ]);
        return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
    }

    async findManagerById(id: string) {
        const m = await this.prisma.managerProfile.findUnique({
            where: { id },
            include: {
                state: { select: { id: true, name: true } },
                district: { select: { id: true, name: true } },
                user: { select: { id: true, email: true, mobile: true, createdAt: true } },
                _count: { select: { engineers: true } },
            },
        });
        if (!m) throw new NotFoundException('Manager not found');
        return m;
    }

    // ─── Engineers ────────────────────────────────────────────────────────

    async findAllEngineers(opts: { stateId?: string; managerId?: string; search?: string; page?: number; limit?: number }) {
        const page = opts.page ?? 1;
        const limit = Math.min(opts.limit ?? 20, 100);
        const where: any = {
            ...(opts.stateId ? { stateId: opts.stateId } : {}),
            ...(opts.managerId ? { managerId: opts.managerId } : {}),
            ...(opts.search ? { fullName: { contains: opts.search, mode: 'insensitive' } } : {}),
        };
        const [data, total] = await Promise.all([
            this.prisma.engineer.findMany({
                where,
                skip: (page - 1) * limit,
                take: limit,
                orderBy: { fullName: 'asc' },
                include: {
                    state: { select: { name: true } },
                    district: { select: { name: true } },
                    manager: { select: { fullName: true } },
                },
            }),
            this.prisma.engineer.count({ where }),
        ]);
        return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
    }

    async findEngineerById(id: string) {
        const e = await this.prisma.engineer.findUnique({
            where: { id },
            include: {
                state: { select: { name: true } },
                district: { select: { name: true } },
                manager: { select: { fullName: true } },
            },
        });
        if (!e) throw new NotFoundException('Engineer not found');
        return e;
    }

    async updateEngineer(actorId: string, id: string, data: AdminUpdateEngineerDto) {
        try {
            const engineer = await this.prisma.engineer.update({ where: { id }, data });
            this.audit.log({ actorId, action: 'UPDATE', targetType: 'ENGINEER', targetId: id, metadata: data as any });
            return engineer;
        } catch (e: any) {
            if (e.code === 'P2025') throw new NotFoundException('Engineer not found');
            throw e;
        }
    }

    async deleteEngineer(actorId: string, id: string) {
        try {
            await this.prisma.engineer.delete({ where: { id } });
            this.audit.log({ actorId, action: 'DELETE', targetType: 'ENGINEER', targetId: id });
            return { message: 'Engineer deleted' };
        } catch (e: any) {
            if (e.code === 'P2025') throw new NotFoundException('Engineer not found');
            throw e;
        }
    }

    // ─── Issues (admin view) ──────────────────────────────────────────────

    async findAllIssues(opts: { status?: IssueStatus; page?: number; limit?: number }) {
        const page = opts.page ?? 1;
        const limit = Math.min(opts.limit ?? 20, 100);
        const where: any = opts.status ? { status: opts.status } : {};
        const [data, total] = await Promise.all([
            this.prisma.issue.findMany({
                where,
                skip: (page - 1) * limit,
                take: limit,
                orderBy: { createdAt: 'desc' },
                include: {
                    reporter: {
                        select: {
                            email: true,
                            managerProfile: { select: { fullName: true } },
                        },
                    },
                },
            }),
            this.prisma.issue.count({ where }),
        ]);
        return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
    }

    // ─── Audit Logs ───────────────────────────────────────────────────────

    async findAuditLogs(opts: { page?: number; limit?: number }) {
        const page = opts.page ?? 1;
        const limit = Math.min(opts.limit ?? 50, 200);
        const [data, total] = await Promise.all([
            this.prisma.auditLog.findMany({
                skip: (page - 1) * limit,
                take: limit,
                orderBy: { createdAt: 'desc' },
                include: {
                    actor: { select: { email: true, managerProfile: { select: { fullName: true } } } },
                },
            }),
            this.prisma.auditLog.count(),
        ]);
        return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
    }

    // ==========================================
    // TASPU Website Admin Extensions
    // ==========================================

    async getDashboardStats() {
      const startOfMonth = new Date();
      startOfMonth.setDate(1);
      startOfMonth.setHours(0, 0, 0, 0);

      const [totalMembers, pendingApps, thisMonthApps, publishedNews, unreadMessages, recentApps] = await Promise.all([
        this.prisma.member.count({ where: { status: 'ACTIVE' } }),
        this.prisma.membershipApplication.count({ where: { status: 'PENDING' } }),
        this.prisma.membershipApplication.count({ where: { submittedAt: { gte: startOfMonth } } }),
        this.prisma.newsArticle.count({ where: { status: 'PUBLISHED' } }),
        this.prisma.contactMessage.count({ where: { isRead: false } }),
        this.prisma.membershipApplication.findMany({
          take: 5,
          orderBy: { submittedAt: 'desc' },
          select: {
            id: true,
            fullName: true,
            serviceCenterName: true,
            district: true,
            submittedAt: true,
            status: true,
          },
        }),
      ]);

      return {
        totalMembers,
        pendingApps,
        thisMonthApps,
        publishedNews,
        unreadMessages,
        recentApps: recentApps.map(a => ({
          id: a.id,
          full_name: a.fullName,
          service_center_name: a.serviceCenterName,
          district: a.district,
          submitted_at: a.submittedAt.toISOString(),
          status: a.status,
        })),
      };
    }

    async findAllApplications(query: { status?: string; search?: string }) {
      const where: any = {};
      if (query.status && query.status !== 'ALL') {
        where.status = query.status;
      }
      if (query.search) {
        where.OR = [
          { fullName: { contains: query.search, mode: 'insensitive' } },
          { serviceCenterName: { contains: query.search, mode: 'insensitive' } },
          { applicationNumber: { contains: query.search, mode: 'insensitive' } },
        ];
      }

      const apps = await this.prisma.membershipApplication.findMany({
        where,
        orderBy: { submittedAt: 'desc' },
      });

      return apps.map(a => ({
        id: a.id,
        application_number: a.applicationNumber,
        full_name: a.fullName,
        phone: a.phone,
        service_center_name: a.serviceCenterName,
        submitted_at: a.submittedAt.toISOString(),
        status: a.status,
      }));
    }

    async findApplicationById(id: string) {
      const app = await this.prisma.membershipApplication.findUnique({ where: { id } });
      if (!app) return null;

      const rawDocs = Array.isArray(app.documents) ? (app.documents as any[]) : [];
      const documentsWithUrls = await Promise.all(
        rawDocs.map(async (doc: any) => {
          let url: string | null = null;
          if (doc.key) {
            try {
              url = await this.s3Service.getPresignedDownloadUrl(doc.key, 3600);
            } catch (e) {
              // Ignore S3 error gracefully if object key is missing/unreachable
            }
          }
          return {
            name: doc.originalName || doc.name || 'Document',
            key: doc.key,
            size: doc.size ? `${(doc.size / 1024).toFixed(0)} KB` : '—',
            mimeType: doc.mimeType,
            url,
          };
        })
      );

      return {
        ...app,
        full_name: app.fullName,
        service_center_name: app.serviceCenterName,
        application_number: app.applicationNumber,
        years_experience: app.yearsExperience,
        brands_worked_with: app.brandsWorkedWith,
        gst_no: app.gstNo,
        full_address: app.fullAddress,
        reason_for_joining: app.reasonForJoining,
        additional_info: app.additionalInfo,
        admin_notes: app.adminNotes,
        documents: documentsWithUrls,
        submitted_at: app.submittedAt.toISOString(),
      };
    }

    async approveApplication(id: string, adminId: string) {
      return this.prisma.$transaction(async (tx) => {
        const app = await tx.membershipApplication.findUnique({ where: { id } });
        if (!app) throw new BadRequestException('Application not found');
        if (app.status === 'APPROVED') throw new BadRequestException('Application is already approved');

        const settings = await tx.siteSettings.findUnique({ where: { id: 1 } });
        const prefix = settings?.membershipIdPrefix || 'TASPU';
        const year = settings?.membershipIdYear || new Date().getFullYear().toString();

        const memberCount = await tx.member.count();
        const membershipId = `${prefix}-${year}-${String(memberCount + 1).padStart(5, '0')}`;

        await tx.membershipApplication.update({
          where: { id },
          data: {
            status: 'APPROVED',
            reviewedAt: new Date(),
            reviewedBy: adminId || null,
          },
        });

        const member = await tx.member.create({
          data: {
            membershipId,
            applicationId: id,
            fullName: app.fullName,
            serviceCenterName: app.serviceCenterName,
            district: app.district,
            city: app.city,
            phone: app.phone,
            email: app.email,
            fullAddress: app.fullAddress,
            brandsWorkedWith: app.brandsWorkedWith,
            gstNo: app.gstNo,
            status: 'ACTIVE',
          },
        });

        await tx.auditLog.create({
          data: {
            actorId: adminId || null,
            action: 'APPROVE_APPLICATION',
            targetType: 'MEMBERSHIP_APPLICATION',
            targetId: id,
            metadata: { membershipId, memberId: member.id },
          },
        });

        return { success: true, membership_id: membershipId, member_id: member.id };
      });
    }

    async updateApplicationStatus(id: string, adminId: string, dto: any) {
      if (dto.status === 'APPROVED') {
        return this.approveApplication(id, adminId);
      }

      await this.prisma.membershipApplication.update({
        where: { id },
        data: {
          status: dto.status,
          reviewedAt: new Date(),
          reviewedBy: adminId || null,
          adminNotes: dto.adminNotes !== undefined ? dto.adminNotes : undefined,
          rejectionReason: dto.status === 'REJECTED' ? (dto.adminNotes || null) : undefined,
        },
      });

      return { success: true };
    }

    async saveApplicationNotes(id: string, notes: string) {
      await this.prisma.membershipApplication.update({
        where: { id },
        data: { adminNotes: notes },
      });
      return { success: true };
    }

    async findAllMembers(query: { status?: string; search?: string }) {
      const where: any = {};
      if (query.status && query.status !== 'ALL') {
        where.status = query.status;
      }
      if (query.search) {
        where.OR = [
          { fullName: { contains: query.search, mode: 'insensitive' } },
          { serviceCenterName: { contains: query.search, mode: 'insensitive' } },
          { membershipId: { contains: query.search, mode: 'insensitive' } },
        ];
      }

      const members = await this.prisma.member.findMany({
        where,
        orderBy: { membershipDate: 'desc' },
      });

      return members.map(m => ({
        id: m.id,
        membership_id: m.membershipId,
        application_id: m.applicationId,
        full_name: m.fullName,
        service_center_name: m.serviceCenterName,
        district: m.district,
        city: m.city,
        phone: m.phone,
        email: m.email,
        membership_date: m.membershipDate.toISOString(),
        status: m.status,
      }));
    }

    async findMemberById(id: string) {
      const member = await this.prisma.member.findUnique({
        where: { id },
        include: { application: true },
      });
      if (!member) return null;

      return {
        id: member.id,
        membership_id: member.membershipId,
        application_id: member.applicationId,
        full_name: member.fullName,
        service_center_name: member.serviceCenterName,
        district: member.district,
        city: member.city,
        phone: member.phone,
        email: member.email,
        full_address: member.fullAddress,
        brands_worked_with: member.brandsWorkedWith,
        gst_no: member.gstNo,
        membership_date: member.membershipDate.toISOString(),
        status: member.status,
        application: member.application ? {
          id: member.application.id,
          application_number: member.application.applicationNumber,
          submitted_at: member.application.submittedAt.toISOString(),
          status: member.application.status,
          reason_for_joining: member.application.reasonForJoining,
          additional_info: member.application.additionalInfo,
          admin_notes: member.application.adminNotes,
          designation: member.application.designation,
          years_experience: member.application.yearsExperience,
        } : null,
      };
    }

    async toggleMemberSuspension(id: string, currentStatus: string) {
      const newStatus = currentStatus === 'SUSPENDED' ? 'ACTIVE' : 'SUSPENDED';
      await this.prisma.member.update({
        where: { id },
        data: { status: newStatus },
      });
      return { success: true, newStatus };
    }

    async createManualMember(dto: any) {
      await this.prisma.member.create({
        data: {
          membershipId: dto.membershipId,
          fullName: dto.fullName,
          serviceCenterName: dto.serviceCenterName,
          brandsWorkedWith: dto.brandsWorkedWith || [],
          gstNo: dto.gstNo || '',
          fullAddress: dto.fullAddress || '',
          district: dto.district,
          city: dto.city,
          phone: dto.phone,
          email: dto.email,
          status: 'ACTIVE',
        },
      });
      return { success: true };
    }

    async updateMember(id: string, dto: any) {
      await this.prisma.member.update({
        where: { id },
        data: {
          membershipId: dto.membershipId,
          fullName: dto.fullName,
          serviceCenterName: dto.serviceCenterName,
          brandsWorkedWith: dto.brandsWorkedWith || [],
          gstNo: dto.gstNo || '',
          fullAddress: dto.fullAddress || '',
          district: dto.district,
          city: dto.city,
          phone: dto.phone,
          email: dto.email,
        },
      });
      return { success: true };
    }

    async getNews() {
      return this.prisma.newsArticle.findMany({ orderBy: { createdAt: 'desc' } });
    }

    async getMessages() {
      return this.prisma.contactMessage.findMany({ orderBy: { createdAt: 'desc' } });
    }

    async getLeadership() {
      return this.prisma.leadership.findMany({ where: { isActive: true }, orderBy: { sortOrder: 'asc' } });
    }

    async getSettings() {
      const s = await this.prisma.siteSettings.findUnique({ where: { id: 1 } });
      return s || { membershipIdPrefix: 'TASPU', membershipIdYear: '2026', appIdPrefix: 'TASPU-APP' };
    }
}
