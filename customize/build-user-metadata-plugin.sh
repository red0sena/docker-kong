u#!/bin/bash

# User Metadata Plugin 빌드 스크립트

echo "Building Kong with User Metadata Plugin..."

# 현재 디렉토리 확인
if [ ! -d "user-metadata-plugin" ]; then
    echo "Error: user-metadata-plugin directory not found"
    exit 1
fi

# Docker 이미지 빌드
echo "Building Docker image..."
docker build -f Dockerfile.user-metadata -t kong-with-user-metadata .

if [ $? -eq 0 ]; then
    echo "✅ Successfully built kong-with-user-metadata image"
    echo ""
    echo "To use this image, update your docker-compose.yml:"
    echo "  image: kong-with-user-metadata"
    echo ""
    echo "Or run Kong directly:"
    echo "  docker run -d --name kong-with-metadata kong-with-user-metadata"
else
    echo "❌ Failed to build Docker image"
    exit 1
fi
