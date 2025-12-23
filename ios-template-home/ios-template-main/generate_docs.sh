#!/bin/bash

# Script to generate API documentation using DocC
# Usage: ./generate_docs.sh

set -e  # Exit on error

echo "📚 Generating API Documentation for iOS Template..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
SCHEME="iOSTemplate"
OUTPUT_DIR="./docs/generated"
ARCHIVE_PATH="./build/iOSTemplate.xcarchive"

# Step 1: Clean previous builds
echo -e "${BLUE}1. Cleaning previous builds...${NC}"
rm -rf ./build
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
echo -e "${GREEN}✓ Clean complete${NC}\n"

# Step 2: Build documentation
echo -e "${BLUE}2. Building documentation with DocC...${NC}"

swift package \
    --allow-writing-to-directory "$OUTPUT_DIR" \
    generate-documentation \
    --target iOSTemplate \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path ios-template \
    --output-path "$OUTPUT_DIR"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Documentation generated successfully${NC}\n"
else
    echo -e "${RED}✗ Documentation generation failed${NC}\n"
    exit 1
fi

# Step 3: Summary
echo -e "${BLUE}3. Documentation Summary${NC}"
echo "Output location: $OUTPUT_DIR"
echo ""
echo "To view documentation locally:"
echo "  1. Open: $OUTPUT_DIR/index.html"
echo "  2. Or run: python3 -m http.server --directory $OUTPUT_DIR 8000"
echo "     Then open: http://localhost:8000"
echo ""

# Step 4: Create index file if needed
if [ ! -f "$OUTPUT_DIR/index.html" ]; then
    echo -e "${BLUE}4. Creating index.html redirect...${NC}"
    cat > "$OUTPUT_DIR/index.html" <<EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>iOS Template Documentation</title>
    <meta http-equiv="refresh" content="0; url=documentation/iostemplate/">
</head>
<body>
    <p>Redirecting to <a href="documentation/iostemplate/">iOS Template Documentation</a>...</p>
</body>
</html>
EOF
    echo -e "${GREEN}✓ Index file created${NC}\n"
fi

echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Documentation generation complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
