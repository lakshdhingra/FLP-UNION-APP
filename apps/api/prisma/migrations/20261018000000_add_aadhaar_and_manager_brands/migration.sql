-- AlterTable
ALTER TABLE "ManagerProfile" ADD COLUMN "brandsWorkedWith" TEXT[] DEFAULT ARRAY[]::TEXT[];

-- AlterTable
ALTER TABLE "Engineer" ADD COLUMN "aadhaarCardUrl" TEXT;
