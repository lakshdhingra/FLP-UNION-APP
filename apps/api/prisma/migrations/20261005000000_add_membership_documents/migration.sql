-- AlterTable
ALTER TABLE "MembershipApplication" ADD COLUMN "documents" JSONB DEFAULT '[]'::jsonb;
