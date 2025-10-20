#!/bin/bash

# XanoScript API Group Fix - Patch Application Script (Git-based)
# This script applies patches using git patch format instead of copying files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration from .env file if it exists
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
fi

# Default values (can be overridden by .env or command line arguments)
PATCH_FILE_NAME="${PATCH_FILE:-api-group-fix.patch}"
PATCH_FILE="$SCRIPT_DIR/$PATCH_FILE_NAME"
DEFAULT_EXTENSION_PATH="${EXTENSION_PATH:-}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}XanoScript API Group Fix v3.0${NC}"
echo -e "${BLUE}Patch-based Application System${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Function to display usage
usage() {
    echo "Usage: $0 [target_extension_path]"
    echo ""
    echo "Configuration:"
    echo "  Create a .env file in the script directory to set default paths."
    echo "  See .env.example for available options."
    echo ""
    echo "Arguments:"
    echo "  target_extension_path   Path to extension (optional if set in .env)"
    echo ""
    echo "Examples:"
    echo "  $0 /Users/user/vscode_plugins/xano73"
    echo "  $0 ~/.vscode/extensions/xano.xanoscript-0.0.73"
    echo "  $0  # Uses EXTENSION_PATH from .env"
    echo ""
    echo "This script will apply patches to:"
    echo "  1. out/registry/xsUtils.js"
    echo "  2. out/registry/pull.js"
    echo "  3. dist/extension.js"
    echo ""
    echo "Fixes applied:"
    echo "  • Null check for API groups without xanoscript"
    echo "  • Deduplication of API groups (remove id=0)"
    echo "  • Parent directory creation"
    echo "  • Proper comparison for API groups"
    exit 1
}

# Determine target path (command line argument or .env)
if [ -n "$1" ]; then
    TARGET_PATH="$1"
elif [ -n "$DEFAULT_EXTENSION_PATH" ]; then
    TARGET_PATH="$DEFAULT_EXTENSION_PATH"
    # Expand tilde if present
    TARGET_PATH="${TARGET_PATH/#\~/$HOME}"
    echo -e "${BLUE}Using extension path from .env: $TARGET_PATH${NC}"
    echo ""
else
    echo -e "${RED}Error: Target extension path not provided${NC}"
    echo -e "${YELLOW}Tip: Provide path as argument or set EXTENSION_PATH in .env${NC}"
    echo ""
    usage
fi
XSUTILS_FILE="$TARGET_PATH/out/registry/xsUtils.js"
PULL_FILE="$TARGET_PATH/out/registry/pull.js"
EXTENSION_FILE="$TARGET_PATH/dist/extension.js"

# Verify target path exists
if [ ! -d "$TARGET_PATH" ]; then
    echo -e "${RED}Error: Target path does not exist: $TARGET_PATH${NC}"
    exit 1
fi

# Verify patch file exists
if [ ! -f "$PATCH_FILE" ]; then
    echo -e "${RED}Error: Patch file not found: $PATCH_FILE${NC}"
    exit 1
fi

# Verify target files exist
if [ ! -f "$XSUTILS_FILE" ]; then
    echo -e "${RED}Error: xsUtils.js not found${NC}"
    echo -e "${YELLOW}Expected: $XSUTILS_FILE${NC}"
    exit 1
fi

if [ ! -f "$PULL_FILE" ]; then
    echo -e "${RED}Error: pull.js not found${NC}"
    echo -e "${YELLOW}Expected: $PULL_FILE${NC}"
    exit 1
fi

if [ ! -f "$EXTENSION_FILE" ]; then
    echo -e "${RED}Error: extension.js not found${NC}"
    echo -e "${YELLOW}Expected: $EXTENSION_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}Target extension:${NC} $TARGET_PATH"
echo ""

# Check if already patched
echo -e "${YELLOW}Checking current patch status...${NC}"

PATCHED_XSUTILS=false
PATCHED_PULL_DEDUP=false
PATCHED_PULL_COMPARE=false
PATCHED_PULL_MKDIR=false
PATCHED_EXTENSION=false

if grep -q "API groups don't have xanoscript content" "$XSUTILS_FILE" 2>/dev/null; then
    PATCHED_XSUTILS=true
    echo -e "${GREEN}  ✓${NC} xsUtils.js: Already has null check"
fi

if grep -q "Clean api_group duplicates before saving registry" "$PULL_FILE" 2>/dev/null; then
    PATCHED_PULL_DEDUP=true
    echo -e "${GREEN}  ✓${NC} pull.js: Already has deduplication"
fi

if grep -q "For api_group and other objects without xanoscript, compare with generated content" "$PULL_FILE" 2>/dev/null; then
    PATCHED_PULL_COMPARE=true
    echo -e "${GREEN}  ✓${NC} pull.js: Already has proper comparison"
fi

if grep -q "Ensure parent directory exists before creating the file" "$PULL_FILE" 2>/dev/null; then
    PATCHED_PULL_MKDIR=true
    echo -e "${GREEN}  ✓${NC} pull.js: Already creates parent directories"
fi

if grep -q 'if(!r.xanoscript)return `api_group' "$EXTENSION_FILE" 2>/dev/null; then
    PATCHED_EXTENSION=true
    echo -e "${GREEN}  ✓${NC} extension.js: Already has null check (minified)"
fi

echo ""

# Check if fully patched
if [ "$PATCHED_XSUTILS" = true ] && [ "$PATCHED_PULL_DEDUP" = true ] && [ "$PATCHED_PULL_COMPARE" = true ] && [ "$PATCHED_PULL_MKDIR" = true ] && [ "$PATCHED_EXTENSION" = true ]; then
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Extension is FULLY patched!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo ""
    echo "All fixes are already applied:"
    echo "  ✓ xsUtils.js - Null check"
    echo "  ✓ pull.js - Deduplication"
    echo "  ✓ pull.js - Comparison fix"
    echo "  ✓ pull.js - Parent directory creation"
    echo "  ✓ extension.js - Null check (minified)"
    echo ""
    exit 0
fi

# Show what needs patching
echo -e "${YELLOW}Fixes needed:${NC}"
[ "$PATCHED_XSUTILS" = false ] && echo -e "${RED}  ✗${NC} xsUtils.js - Needs null check"
[ "$PATCHED_PULL_DEDUP" = false ] && echo -e "${RED}  ✗${NC} pull.js - Needs deduplication"
[ "$PATCHED_PULL_COMPARE" = false ] && echo -e "${RED}  ✗${NC} pull.js - Needs comparison fix"
[ "$PATCHED_PULL_MKDIR" = false ] && echo -e "${RED}  ✗${NC} pull.js - Needs parent directory creation"
[ "$PATCHED_EXTENSION" = false ] && echo -e "${RED}  ✗${NC} extension.js - Needs null check (minified)"
echo ""

echo -e "${YELLOW}Creating backups...${NC}"
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$TARGET_PATH/.xano-patch-backups/$BACKUP_TIMESTAMP"
mkdir -p "$BACKUP_DIR"

cp "$XSUTILS_FILE" "$BACKUP_DIR/xsUtils.js"
cp "$PULL_FILE" "$BACKUP_DIR/pull.js"
cp "$EXTENSION_FILE" "$BACKUP_DIR/extension.js"

echo -e "${GREEN}  ✓${NC} Created backups in: $BACKUP_DIR"
echo ""

echo -e "${YELLOW}Applying patch using git apply...${NC}"
echo ""

# Change to target directory and apply patch
cd "$TARGET_PATH"

# Try to apply the patch
if git apply --check "$PATCH_FILE" 2>/dev/null; then
    echo -e "${BLUE}Patch can be applied cleanly${NC}"
    git apply "$PATCH_FILE"
    echo -e "${GREEN}✓ Patch applied successfully${NC}"
elif patch --dry-run -p1 < "$PATCH_FILE" >/dev/null 2>&1; then
    echo -e "${BLUE}Using 'patch' command as fallback${NC}"
    patch -p1 < "$PATCH_FILE"
    echo -e "${GREEN}✓ Patch applied successfully${NC}"
else
    echo -e "${YELLOW}Patch cannot be applied directly, trying with reject files...${NC}"

    # Try to apply with rejects
    if git apply --reject "$PATCH_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Patch partially applied with some rejects${NC}"
        echo -e "${YELLOW}Check for .rej files in the target directory${NC}"
    else
        # Last resort: use patch command with rejects
        patch -p1 --reject-file=- < "$PATCH_FILE" || true
        echo -e "${YELLOW}⚠ Patch applied with possible conflicts${NC}"
    fi
fi

echo ""

# Verify the patch was applied
echo -e "${YELLOW}Verifying patch application...${NC}"

VERIFY_FAIL=false

if ! grep -q "API groups don't have xanoscript content" "$XSUTILS_FILE" 2>/dev/null; then
    if [ "$PATCHED_XSUTILS" = false ]; then
        echo -e "${RED}  ✗${NC} xsUtils.js: Null check not applied"
        VERIFY_FAIL=true
    fi
else
    echo -e "${GREEN}  ✓${NC} xsUtils.js: Null check verified"
fi

if ! grep -q "Clean api_group duplicates before saving registry" "$PULL_FILE" 2>/dev/null; then
    if [ "$PATCHED_PULL_DEDUP" = false ]; then
        echo -e "${RED}  ✗${NC} pull.js: Deduplication not applied"
        VERIFY_FAIL=true
    fi
else
    echo -e "${GREEN}  ✓${NC} pull.js: Deduplication verified"
fi

if ! grep -q "For api_group and other objects without xanoscript, compare with generated content" "$PULL_FILE" 2>/dev/null; then
    if [ "$PATCHED_PULL_COMPARE" = false ]; then
        echo -e "${RED}  ✗${NC} pull.js: Comparison fix not applied"
        VERIFY_FAIL=true
    fi
else
    echo -e "${GREEN}  ✓${NC} pull.js: Comparison fix verified"
fi

if ! grep -q "Ensure parent directory exists before creating the file" "$PULL_FILE" 2>/dev/null; then
    if [ "$PATCHED_PULL_MKDIR" = false ]; then
        echo -e "${RED}  ✗${NC} pull.js: Parent directory creation not applied"
        VERIFY_FAIL=true
    fi
else
    echo -e "${GREEN}  ✓${NC} pull.js: Parent directory creation verified"
fi

if ! grep -q 'if(!r.xanoscript)return `api_group' "$EXTENSION_FILE" 2>/dev/null; then
    if [ "$PATCHED_EXTENSION" = false ]; then
        echo -e "${RED}  ✗${NC} extension.js: Null check not applied"
        VERIFY_FAIL=true
    fi
else
    echo -e "${GREEN}  ✓${NC} extension.js: Null check verified"
fi

echo ""

if [ "$VERIFY_FAIL" = true ]; then
    echo -e "${RED}═══════════════════════════════════════${NC}"
    echo -e "${RED}⚠ Patch verification failed!${NC}"
    echo -e "${RED}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}To restore from backup:${NC}"
    echo "  cp $BACKUP_DIR/xsUtils.js $XSUTILS_FILE"
    echo "  cp $BACKUP_DIR/pull.js $PULL_FILE"
    echo "  cp $BACKUP_DIR/extension.js $EXTENSION_FILE"
    echo ""
    exit 1
fi

echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Patches Applied Successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}What was fixed:${NC}"
echo "  ✓ xsUtils.js: Null check for obj.xanoscript"
echo "  ✓ pull.js: API group deduplication (removes id=0)"
echo "  ✓ pull.js: Proper comparison for API groups"
echo "  ✓ pull.js: Parent directory creation"
echo "  ✓ extension.js: Null check in minified bundle (critical for id=0 fix)"
echo ""
echo -e "${YELLOW}Backup location:${NC}"
echo "  $BACKUP_DIR"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Reload your IDE window (Cmd+R or Ctrl+R)"
echo "  2. Pull changes from Xano"
echo "  3. Verify API groups have proper IDs (not 0)"
echo "  4. Check that API groups appear in file tree"
echo ""

exit 0
