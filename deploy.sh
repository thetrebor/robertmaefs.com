#!/usr/bin/env bash
# Deploy robertmaefs.com homepage and contact form infrastructure
set -euo pipefail

BUCKET="robertmaefs.com"
DOMAIN="robertmaefs.com"
API_SUBDOMAIN="api.robertmaefs.com"
LAMBDA_ZIP="/tmp/contact-lambda.zip"
STACK_NAME="robertmaefs-contact"

echo "==> Uploading homepage to S3..."
aws s3 sync . s3://$BUCKET --exclude ".git/*" --exclude "lambda/*" --exclude "deploy.sh" --exclude "README.md"

echo "==> Building Lambda package..."
cd lambda
pip install -r requirements.txt -t /tmp/lambda-pkg 2>/dev/null || true
cp contact_handler.py /tmp/lambda-pkg/
cd /tmp/lambda-pkg
zip -r $LAMBDA_ZIP . -q
cd -

echo "==> Deploying CloudFormation stack for contact API..."
aws cloudformation deploy \
  --template-file lambda/api-template.yaml \
  --stack-name $STACK_NAME \
  --parameter-overrides \
    DomainName=$DOMAIN \
    ApiSubdomain=$API_SUBDOMAIN \
    ToEmail=hello@$DOMAIN \
    FromEmail=noreply@$DOMAIN \
  --capabilities CAPABILITY_IAM

echo "==> Invalidating CloudFront cache..."
DIST_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?Aliases.Items[?contains(@,'app.$DOMAIN')]].Id" --output text)
if [ -n "$DIST_ID" ]; then
  aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*" --no-cli-pager > /dev/null
  echo "  Cache invalidated."
fi

echo ""
echo "✅ Deploy complete!"
echo "  Site:   https://$DOMAIN"
echo "  API:    https://$API_SUBDOMAIN/contact"
echo ""
echo "⚠️  Don't forget to verify your SES sending address!"
echo "  aws ses verify-email-identity --email-address hello@$DOMAIN"
echo "  Then check your inbox and confirm the verification link."
