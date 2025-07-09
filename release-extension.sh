#!/usr/bin/env bash

# Script to create a desktop extension release
# Usage: ./release-extension.sh [version]
# Example: ./release-extension.sh 1.0.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if version argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Version number required${NC}"
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

VERSION="$1"
VERSION_CLEAN=$(echo "$VERSION" | sed 's/^v//')
TAG_NAME="v${VERSION_CLEAN}-ext"

echo -e "${GREEN}🚀 Creating Desktop Extension Release: ${TAG_NAME}${NC}"
echo ""

# Check if we're on the right branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "desktop-extension-stable" ]; then
    echo -e "${YELLOW}Warning: Not on desktop-extension-stable branch${NC}"
    echo "Current branch: $CURRENT_BRANCH"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Error: You have uncommitted changes${NC}"
    echo "Please commit or stash your changes before creating a release."
    exit 1
fi

# Check if tag already exists
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    echo -e "${RED}Error: Tag $TAG_NAME already exists${NC}"
    echo "Please use a different version number."
    exit 1
fi

# Run the justfile command
echo "Running: just release-extension $VERSION"
just release-extension "$VERSION"

echo ""
echo -e "${GREEN}✅ Release preparation complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Push the tag to trigger automated build:"
echo "   ${YELLOW}git push origin $TAG_NAME${NC}"
echo ""
echo "2. Monitor the build progress:"
echo "   https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:\/]\([^\/]*\/[^\/]*\).*/\1/' | sed 's/.git$//')/actions"
echo ""
echo "3. Once complete, find the .dxt file at:"
echo "   https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:\/]\([^\/]*\/[^\/]*\).*/\1/' | sed 's/.git$//')/releases/tag/$TAG_NAME"