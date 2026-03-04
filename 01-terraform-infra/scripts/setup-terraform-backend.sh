#!/usr/bin/env bash
set -euo pipefail

export AWS_PAGER=""

# Provisions Terraform state backend: S3 bucket + IAM role for cross-account access.

# Usage:
#   export AWS_PROFILE=<profile-with-admin-in-target-account>
#   ./setup-terraform-backend.sh <TARGET_ACCOUNT_ID> <MANAGEMENT_ACCOUNT_ID>

# Example:
#   ./setup-terraform-backend.sh 188494185951 438950223046

TARGET_ACCOUNT_ID="${1:?Usage: $0 <TARGET_ACCOUNT_ID> <MANAGEMENT_ACCOUNT_ID>}"
MANAGEMENT_ACCOUNT_ID="${2:?Usage: $0 <TARGET_ACCOUNT_ID> <MANAGEMENT_ACCOUNT_ID>}"
REGION="eu-central-1"
BUCKET="tfstate-${TARGET_ACCOUNT_ID}"
ROLE_NAME="TerraformExecutionRole"

echo "==> Provisioning Terraform backend for account ${TARGET_ACCOUNT_ID}"

if aws s3api head-bucket --bucket "${BUCKET}" 2>/dev/null; then
  echo "    S3 bucket ${BUCKET} already exists — skipping."
else
  echo "    Creating S3 bucket ${BUCKET} ..."
  aws s3api create-bucket \
    --bucket "${BUCKET}" \
    --region "${REGION}" \
    --create-bucket-configuration LocationConstraint="${REGION}"

  aws s3api put-bucket-versioning \
    --bucket "${BUCKET}" \
    --versioning-configuration Status=Enabled

  aws s3api put-bucket-encryption \
    --bucket "${BUCKET}" \
    --server-side-encryption-configuration '{
      "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "aws:kms"},"BucketKeyEnabled": true}]
    }'

  aws s3api put-public-access-block \
    --bucket "${BUCKET}" \
    --public-access-block-configuration \
      BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

  echo "S3 bucket ${BUCKET} created."
fi

TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${MANAGEMENT_ACCOUNT_ID}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)

if aws iam get-role --role-name "${ROLE_NAME}" 2>/dev/null; then
  echo "IAM role ${ROLE_NAME} already exists — updating trust policy."
  aws iam update-assume-role-policy \
    --role-name "${ROLE_NAME}" \
    --policy-document "${TRUST_POLICY}"
else
  echo "Creating IAM role ${ROLE_NAME} ..."
  aws iam create-role \
    --role-name "${ROLE_NAME}" \
    --assume-role-policy-document "${TRUST_POLICY}" \
    --description "Role assumed by Terraform/Terragrunt from the management account"
fi

aws iam attach-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"

echo "IAM role ${ROLE_NAME} ready."
echo "Terraform backend provisioned for account ${TARGET_ACCOUNT_ID}."