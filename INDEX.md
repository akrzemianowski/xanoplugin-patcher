# XanoScript Patch - File Index

Complete reference of all files in this package.

## Quick Navigation

**New to patching?** → Start with [QUICKSTART.md](QUICKSTART.md)
**Need overview?** → Check [SUMMARY.md](SUMMARY.md)
**Full documentation?** → Read [README.md](README.md)

---

## Core Files

### Scripts

#### apply-patch.sh - 9.9 KB ⭐
**Main patch application script**

The primary script for applying patches. Uses git patches to apply fixes.

```bash
./apply-patch.sh /path/to/extension
```

Features:
- Git-based patching (surgical changes only)
- Auto-detection of already-patched files
- Organized backups in `.xano-patch-backups/`
- Fallback to `patch` command if `git apply` fails
- Comprehensive verification

**When to use:** Always (for all installations)


### Configuration

#### .env.example - 0.3 KB ⭐
**Example configuration file**

Template for setting up local environment paths.

```bash
cp .env.example .env
nano .env
```

**Settings:**
- `REPO_PATH` - Path to source repository
- `EXTENSION_PATH` - Default extension path
- `PATCH_FILE` - Patch file name
- `COMMIT` - Git commit to use

**When to use:** First time setup or when paths change

---
---

#### generate-patch.sh - 4.8 KB ⭐
**Automatic patch generator from git repository**

Extracts changes from `xanoscript_vscode_plugin` repository and creates patch file.

```bash
./generate-patch.sh [options]
```

Options:
- `-r, --repo PATH` - Custom repository path
- `-o, --output FILE` - Custom output file
- `-c, --commit HASH` - Specific commit

**When to use:** When updating the patch after source code changes

---

### Patch Files

#### api-group-fix.patch - 9.8 KB ⭐
**Git format patch file containing all fixes**

Generated from git commit using `git format-patch`.

Contains changes for:
- `out/registry/xsUtils.js` - Null check
- `out/registry/pull.js` - Deduplication, mkdir, comparison
- `dist/extension.js` - Minified null check

**Format:** Git unified diff format
**Portable:** Yes, self-contained
**Reviewable:** Yes, human-readable

---

## Documentation

### README.md - 5.1 KB ⭐
**Main documentation and quick start**

Overview of features, installation instructions, and basic usage.

**Read this:** If you want a general overview

---

### QUICKSTART.md - 4.3 KB ⭐
**60-second installation guide**

Step-by-step instructions for:
- End users (basic patching)
- Developers (patch generation)
- Common scenarios

**Read this:** If you want to patch now, documentation later

---

### SUMMARY.md - 6.7 KB ⭐
**Technical summary and overview**

High-level overview:
- Architecture
- Workflow
- Technical details
- Statistics and metrics

**Read this:** If you want a bird's-eye view

---

### INDEX.md ⭐
**Complete file index and navigation guide**

This file - helps you navigate all documentation and find what you need.

**Read this:** If you're looking for a specific file or topic

---

## File Organization

### By Purpose

**Want to patch an extension?**
- apply-patch.sh ⭐
- api-group-fix.patch

**Want to generate a new patch?**
- generate-patch.sh ⭐

**Want to learn how it works?**
- QUICKSTART.md ⭐
- SUMMARY.md ⭐
- README.md

**Need reference?**
- INDEX.md (this file)

### By File Type

**Executable Scripts (.sh)**
```
apply-patch.sh           (recommended) ⭐
generate-patch.sh        (for developers) ⭐
```

**Patch Files (.patch)**
```
api-group-fix.patch      ⭐
```

**Documentation (.md)**
```
README.md         ⭐
QUICKSTART.md     ⭐
SUMMARY.md        ⭐
INDEX.md          ⭐
```

---

## Minimal Distribution Package

Want to share just the essentials? Include these files:

```
patch/
  apply-patch.sh         (10 KB) - Required
  api-group-fix.patch    (10 KB) - Required
  README.md              (5 KB)  - Recommended
```

**Total size:** ~25 KB (or ~20 KB without docs)

---

## Full Distribution Package

Complete package with all documentation:

```
patch/
  Core:
    apply-patch.sh
    generate-patch.sh
    api-group-fix.patch

  Documentation:
    README.md
    QUICKSTART.md
    SUMMARY.md
    INDEX.md
```

**Total size:** ~50 KB

---

## Quick Reference Matrix

| File | Size | Purpose |
|------|------|---------|
| apply-patch.sh | 10K | Apply patches |
| generate-patch.sh | 5K | Generate patches |
| api-group-fix.patch | 10K | Patch file |
| QUICKSTART.md | 4K | Quick guide |
| SUMMARY.md | 7K | Overview |
| README.md | 5K | Main docs |
| INDEX.md | - | This file |

**Legend:**
- ⭐ = Core file
- Size in KB (approximate)

---

## File Dependencies

### apply-patch.sh Dependencies
```
Requires:
  - api-group-fix.patch (same directory)
  - git or patch command (system)
  - bash shell

Optional:
  - Documentation files (for reference)
```

### generate-patch.sh Dependencies
```
Requires:
  - git repository access
  - git format-patch command
  - bash shell

Generates:
  - api-group-fix.patch
```

---

## Getting Started

1. **First time user?**
   - Start with QUICKSTART.md
   - Run `./apply-patch.sh /path/to/extension`

2. **Developer?**
   - Read SUMMARY.md
   - Use `./generate-patch.sh` to update patches

3. **Need help?**
   - Check README.md
   - Review this index for file reference

---

## What Gets Fixed

Running `apply-patch.sh` fixes these 4 issues:

1. **Null Safety** - Prevents crashes when API groups lack xanoscript content
2. **ID Deduplication** - Removes duplicate API groups with id=0
3. **Directory Creation** - Ensures parent directories exist
4. **Comparison Logic** - Proper comparison for API groups without xanoscript

**Files modified:**
- `out/registry/xsUtils.js`
- `out/registry/pull.js`
- `dist/extension.js` (critical!)

---

## Usage Examples

### Basic Patching
```bash
chmod +x *.sh
./apply-patch.sh /path/to/extension
```

### Generating New Patch
```bash
./generate-patch.sh
```

### From Specific Commit
```bash
./generate-patch.sh --commit abc123
```

### Verify Manually
```bash
grep "API groups don't have xanoscript content" /path/to/extension/out/registry/xsUtils.js
grep "Clean api_group duplicates" /path/to/extension/out/registry/pull.js
grep 'if(!r.xanoscript)return `api_group' /path/to/extension/dist/extension.js
```

---

**Last Updated:** 2025-10-20
**Package Version:** 3.0.0
**Total Files:** 7
**Total Size:** ~50 KB

**Maintained by:** Adam Krzemianowski
**For:** XanoScript VSCode Extension
