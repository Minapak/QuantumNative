# QuantumNative Website Deployment Guide

## File Structure

```
WebAssets/
├── index.html              # Main landing page
├── favicon.png             # (add your favicon)
└── legal/
    ├── index.html          # Legal landing page
    ├── privacy-policy.html # English
    ├── privacy-policy-ko.html # Korean
    ├── privacy-policy-ja.html # Japanese
    ├── privacy-policy-zh.html # Chinese
    ├── privacy-policy-de.html # German
    └── terms-of-service.html # Terms of Service
```

## Deployment to AWS S3 + CloudFront

### Option 1: Using AWS CLI

```bash
# 1. Create S3 bucket (if not exists)
aws s3 mb s3://swiftquantum-website --region ap-northeast-2

# 2. Enable static website hosting
aws s3 website s3://swiftquantum-website \
    --index-document index.html \
    --error-document index.html

# 3. Sync files to S3
aws s3 sync ./WebAssets s3://swiftquantum-website \
    --acl public-read \
    --cache-control "max-age=86400" \
    --delete

# 4. Set HTML files with no-cache for fresh content
aws s3 cp ./WebAssets/index.html s3://swiftquantum-website/index.html \
    --acl public-read \
    --content-type "text/html" \
    --cache-control "no-cache"

# 5. Sync legal folder
aws s3 sync ./WebAssets/legal s3://swiftquantum-website/legal \
    --acl public-read \
    --content-type "text/html"
```

### Option 2: S3 Bucket Policy (for public access)

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::swiftquantum-website/*"
        }
    ]
}
```

### CloudFront Distribution (Recommended)

1. Create CloudFront distribution pointing to S3 bucket
2. Set alternate domain name: `swiftquantum.tech`
3. Request ACM certificate for `swiftquantum.tech`
4. Update Route 53 to point to CloudFront distribution

```bash
# Create CloudFront invalidation after updates
aws cloudfront create-invalidation \
    --distribution-id YOUR_DISTRIBUTION_ID \
    --paths "/*"
```

## Quick Deploy Script

Create `deploy.sh`:

```bash
#!/bin/bash
echo "🚀 Deploying QuantumNative website..."

# Sync to S3
aws s3 sync ./WebAssets s3://swiftquantum-website \
    --acl public-read \
    --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
    --distribution-id YOUR_DISTRIBUTION_ID \
    --paths "/*"

echo "✅ Deployment complete!"
echo "🌐 Visit: https://swiftquantum.tech"
```

## DNS Configuration (Route 53)

| Record Type | Name | Value |
|-------------|------|-------|
| A | swiftquantum.tech | CloudFront Distribution |
| CNAME | www.swiftquantum.tech | swiftquantum.tech |

## Checklist

- [ ] Upload files to S3
- [ ] Configure S3 static website hosting
- [ ] Set bucket policy for public access
- [ ] Create CloudFront distribution
- [ ] Request SSL certificate (ACM)
- [ ] Update Route 53 DNS records
- [ ] Test all URLs:
  - https://swiftquantum.tech
  - https://swiftquantum.tech/legal/
  - https://swiftquantum.tech/legal/privacy-policy.html
  - https://swiftquantum.tech/legal/terms-of-service.html

## App Store URLs

Update these in the app after deployment:
- Privacy Policy: `https://swiftquantum.tech/legal/privacy-policy.html`
- Terms of Service: `https://swiftquantum.tech/legal/terms-of-service.html`
- Marketing URL: `https://swiftquantum.tech`
- Support URL: `https://swiftquantum.tech`
