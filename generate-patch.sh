#!/bin/bash

# XanoScript Patch Generator
# Generates a patch file from the latest commit in xanoscript_vscode_plugin repository

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration from .env file if it exists
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
fi

# Default values (can be overridden by .env or command line arguments)
# REPO_PATH - must be set in .env or via --repo argument (no default)
PATCH_FILE="${PATCH_FILE:-api-group-fix.patch}"
OUTPUT_PATCH="$SCRIPT_DIR/$PATCH_FILE"
COMMIT="${COMMIT:-HEAD}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}XanoScript Patch Generator${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Configuration:"
    echo "  REQUIRED: Create a .env file and set REPO_PATH"
    echo "  See .env.example for all available options."
    echo ""
    echo "Quick setup:"
    echo "  cp .env.example .env"
    echo "  nano .env  # Set REPO_PATH to your repository location"
    echo ""
    echo "Options:"
    echo "  -r, --repo PATH      Path to xanoscript_vscode_plugin repository (REQUIRED if not in .env)"
    echo "  -o, --output FILE    Output patch file name (not full path)"
    echo "                       Default: api-group-fix.patch"
    echo "  -c, --commit HASH    Commit hash to generate patch from"
    echo "                       Default: HEAD"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 --repo /path/to/repo"
    echo "  $0 --commit f6589dc"
    echo "  $0 --output my-patch.patch"
    echo ""
    exit 1
}

# Parse command line arguments (override .env values)
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--repo)
            REPO_PATH="$2"
            shift 2
            ;;
        -o|--output)
            PATCH_FILE="$2"
            OUTPUT_PATCH="$SCRIPT_DIR/$PATCH_FILE"
            shift 2
            ;;
        -c|--commit)
            COMMIT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            usage
            ;;
    esac
done

# Check if REPO_PATH is set
if [ -z "$REPO_PATH" ]; then
    echo -e "${RED}Error: REPO_PATH not set${NC}"
    echo -e "${YELLOW}Set REPO_PATH in .env file or use --repo option${NC}"
    echo ""
    echo "Quick setup:"
    echo "  1. cp .env.example .env"
    echo "  2. Edit .env and set REPO_PATH"
    echo ""
    echo "Or use: $0 --repo /path/to/xanoscript_vscode_plugin"
    exit 1
fi

# Verify repository exists
if [ ! -d "$REPO_PATH" ]; then
    echo -e "${RED}Error: Repository not found: $REPO_PATH${NC}"
    echo -e "${YELLOW}Tip: Check the path in .env or --repo argument${NC}"
    exit 1
fi

# Verify it's a git repository
if [ ! -d "$REPO_PATH/.git" ]; then
    echo -e "${RED}Error: Not a git repository: $REPO_PATH${NC}"
    exit 1
fi

echo -e "${YELLOW}Repository:${NC} $REPO_PATH"
echo -e "${YELLOW}Output patch:${NC} $OUTPUT_PATCH"
echo -e "${YELLOW}Commit:${NC} $COMMIT"
echo ""

# Change to repository directory
cd "$REPO_PATH"

# Get commit information
echo -e "${YELLOW}Extracting commit information...${NC}"
COMMIT_HASH=$(git rev-parse --short "$COMMIT")
COMMIT_SUBJECT=$(git log -1 --format=%s "$COMMIT")
COMMIT_AUTHOR=$(git log -1 --format="%an <%ae>" "$COMMIT")
COMMIT_DATE=$(git log -1 --format=%ad "$COMMIT")

echo -e "${BLUE}Hash:${NC} $COMMIT_HASH"
echo -e "${BLUE}Subject:${NC} $COMMIT_SUBJECT"
echo -e "${BLUE}Author:${NC} $COMMIT_AUTHOR"
echo -e "${BLUE}Date:${NC} $COMMIT_DATE"
echo ""

# Show files that will be included in patch
echo -e "${YELLOW}Files to be patched:${NC}"
git show --name-status --format="" "$COMMIT" | while read -r status file; do
    case $status in
        M)
            echo -e "${YELLOW}  Modified:${NC} $file"
            ;;
        A)
            echo -e "${GREEN}  Added:${NC} $file"
            ;;
        D)
            echo -e "${RED}  Deleted:${NC} $file"
            ;;
        *)
            echo -e "${BLUE}  $status:${NC} $file"
            ;;
    esac
done
echo ""

# Generate the patch
echo -e "${YELLOW}Generating patch file...${NC}"

if git format-patch -1 "$COMMIT" --stdout > "$OUTPUT_PATCH"; then
    echo -e "${GREEN}✓ Patch file generated successfully${NC}"
else
    echo -e "${RED}Error: Failed to generate patch file${NC}"
    exit 1
fi

# Show patch statistics
LINES=$(wc -l < "$OUTPUT_PATCH" | tr -d ' ')
SIZE=$(du -h "$OUTPUT_PATCH" | cut -f1)

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Patch Generated Successfully${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Patch file:${NC} $OUTPUT_PATCH"
echo -e "${YELLOW}Size:${NC} $SIZE ($LINES lines)"
echo ""

# Show first few lines of the patch
echo -e "${YELLOW}Patch preview:${NC}"
echo -e "${BLUE}────────────────────────────────────────${NC}"
head -20 "$OUTPUT_PATCH"
echo -e "${BLUE}... (truncated)${NC}"
echo -e "${BLUE}────────────────────────────────────────${NC}"
echo ""

echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review the patch file: less $OUTPUT_PATCH"
echo "  2. Apply to target extension: ./apply-patch.sh /path/to/extension"
echo ""

exit 0
