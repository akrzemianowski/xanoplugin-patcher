# XanoScript Patch - Quick Start Guide

Get your XanoScript extension patched in 60 seconds!

## For End Users

### Step 1: Configure Paths (Recommended)

```bash
# Navigate to patch directory
cd /path/to/patch

# Copy example configuration
cp .env.example .env

# Edit with your paths
nano .env
# Set EXTENSION_PATH to your extension location
```

### Step 2: Apply the Patch

```bash
# Make scripts executable (first time only)
chmod +x *.sh

# Apply patch (uses .env configuration)
./apply-patch.sh

# Or specify path directly
./apply-patch.sh ~/.vscode/extensions/xano.xanoscript-0.0.73
```

### Step 3: Reload VSCode

- Press `Cmd+R` (Mac) or `Ctrl+R` (Windows/Linux)
- Or: Command Palette → "Developer: Reload Window"

### Step 4: Verify

Open any XanoScript workspace and pull changes. API groups should now:
- ✅ Have real IDs (not 0)
- ✅ Appear in file tree
- ✅ Not show as modified
- ✅ Not cause crashes

---

## For Developers

### Configure Development Environment

```bash
# Copy and edit .env configuration
cp .env.example .env
nano .env

# REQUIRED: Set REPO_PATH to your xanoscript_vscode_plugin repository
# Example: REPO_PATH="/Users/yourname/repos/xanoscript_vscode_plugin"
# This is mandatory for generate-patch.sh to work
```

### Updating the Patch

Made changes in `xanoscript_vscode_plugin` repository?

```bash
# 1. Commit your changes in the source repository
cd $REPO_PATH  # path from your .env (must be set!)
git add .
git commit -m "fix: Your fix description"

# 2. Generate new patch (uses REPO_PATH from .env)
cd /path/to/patch
./generate-patch.sh

# Or with explicit path
./generate-patch.sh --repo /path/to/xanoscript_vscode_plugin

# Done! New patch file is ready
```

### Testing the Patch

```bash
# Test on a clean extension copy
./apply-patch.sh /path/to/test-extension

# Verify all checks pass
./apply-patch.sh /path/to/test-extension
# Should show: "✓ Extension is FULLY patched!"
```

### Distributing the Patch

The patch is self-contained! Just share:

```
patch/
  apply-patch.sh
  api-group-fix.patch
  README.md (optional)
```

Users only need these 2 files to patch their extensions.

---

## Common Scenarios

### Scenario 1: Fresh Installation

```bash
# Install XanoScript extension from VSCode marketplace
# Then patch it
./apply-patch.sh ~/.vscode/extensions/xano.xanoscript-0.0.73
```

### Scenario 2: Already Patched

```bash
# Script detects already patched files
./apply-patch.sh /path/to/extension
# Output: "✓ Extension is FULLY patched!"
```

### Scenario 3: Multiple Extensions

```bash
# Patch all versions
./apply-patch.sh ~/.vscode/extensions/xano.xanoscript-0.0.70
./apply-patch.sh ~/.vscode/extensions/xano.xanoscript-0.0.73
./apply-patch.sh /path/to/custom/extension
```

### Scenario 4: Patch Failed

```bash
# Check what went wrong
./apply-patch.sh /path/to/extension

# Look for reject files
find /path/to/extension -name "*.rej"

# Restore from backup if needed
ls /path/to/extension/.xano-patch-backups/
cp /path/to/extension/.xano-patch-backups/TIMESTAMP/xsUtils.js \
   /path/to/extension/out/registry/xsUtils.js
```

---

## What Gets Fixed?

1. **API Groups Have Real IDs** - No more id=0
2. **API Groups Appear in File Tree** - Proper display
3. **No False "Modified" Status** - Accurate change detection
4. **No Crashes** - Null safety for missing xanoscript content

All fixes are applied in 3 files:
- `out/registry/xsUtils.js`
- `out/registry/pull.js`
- `dist/extension.js` (critical!)

---

## Backup & Safety

### Automatic Backups

Every patch creates a timestamped backup:

```
/path/to/extension/.xano-patch-backups/
  20251020_143022/
    xsUtils.js
    pull.js
    extension.js
```

### Manual Restore

```bash
# List backups
ls -la /path/to/extension/.xano-patch-backups/

# Restore specific file
BACKUP_DIR="/path/to/extension/.xano-patch-backups/20251020_143022"
cp $BACKUP_DIR/xsUtils.js /path/to/extension/out/registry/xsUtils.js
cp $BACKUP_DIR/pull.js /path/to/extension/out/registry/pull.js
cp $BACKUP_DIR/extension.js /path/to/extension/dist/extension.js
```

### Clean Up Old Backups

```bash
# Remove backups older than 30 days
find /path/to/extension/.xano-patch-backups -type d -mtime +30 -exec rm -rf {} +
```

---

## Need Help?

- **[README.md](README.md)** - Full documentation
- **[SUMMARY.md](SUMMARY.md)** - Technical overview
- **[INDEX.md](INDEX.md)** - File reference

---

**Version:** 3.0.0
**Status:** Production Ready ✅
**Last Updated:** 2025-10-20

Happy patching! 🚀
