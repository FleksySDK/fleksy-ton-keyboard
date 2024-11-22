#!/bin/bash

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '#' | xargs)
else
    echo "Error: .env.deploy file not found"
    exit 1
fi

# Validate required environment variables
if [ -z "$BUCKET_NAME" ] || [ -z "$DISTRIBUTION_ID" ] || [ -z "$REACT_APP_PUBLIC_URL" ]; then
    echo "Error: BUCKET_NAME, DISTRIBUTION_ID, and REACT_APP_PUBLIC_URL must be set in .env.deploy"
    exit 1
fi

echo "Deploying to bucket: $BUCKET_NAME"
echo "CloudFront distribution: $DISTRIBUTION_ID"
echo "Public URL: $REACT_APP_PUBLIC_URL"

# Build the application
npm run build

# Remove trailing slash if present and store in a variable
NORMALIZED_URL=${REACT_APP_PUBLIC_URL%/}

# Replace placeholder in manifest (macOS compatible version)
sed -i '' "s|REACT_APP_PUBLIC_URL|$NORMALIZED_URL|g" build/tonconnect-manifest.json

# Deploy to S3 with correct content type for manifest
aws s3 cp build/tonconnect-manifest.json s3://$BUCKET_NAME/tonconnect-manifest.json \
    --content-type "application/json"

# Deploy other files
aws s3 sync build/ s3://$BUCKET_NAME \
    --delete \
    --exclude "tonconnect-manifest.json"

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"

echo "Deployment completed successfully!" 