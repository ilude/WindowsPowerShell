# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Documentation Organization

All project documentation and improvement history is organized in the `.claude/features/` directory with dated subdirectories:

### Feature Directories

**`.claude/features/2025-11-02_initial-code-review/`**
- Initial comprehensive code review findings
- Files: REVIEW_REPORT.md, IMPROVEMENTS_SUMMARY.txt, README_REVIEW.md
- Purpose: Technical analysis of codebase issues and recommendations

**`.claude/features/2025-11-02_phase-1-quick-wins/`**
- Phase 1 quick wins implementation (5/5 complete)
- Files: PHASE_1_COMPLETE.md
- Purpose: Fast, high-impact fixes (typos, cleanup, documentation)

**`.claude/features/2025-11-02_phase-2-code-polish/`**
- Phase 2 code quality improvements (5/5 complete)
- Files: PHASE_2_COMPLETE.md, ADDITIONAL_RECOMMENDATIONS.md
- Purpose: Error handling, code organization, user experience enhancements

**`.claude/features/2025-11-02_roadmap/`**
- Improvement roadmap and planning
- Files: IMPROVEMENT_ROADMAP.txt, PLAN_SUMMARY.md
- Purpose: Strategic planning, effort vs impact analysis, future recommendations

### Navigation Tips

- For quick overview: Start with `.claude/features/2025-11-02_initial-code-review/README_REVIEW.md`
- For implementation details: See individual PHASE_*_COMPLETE.md files
- For strategic planning: Check IMPROVEMENT_ROADMAP.txt in roadmap directory
- For technical specifics: REVIEW_REPORT.md contains detailed bug and fix information

### Future Feature Directories

When working on new features or improvements, dated directories will be created following the pattern:
`.claude/features/YYYY-MM-DD_feature-name/`

---

## Recent Improvements (Latest Review)

**Bug Fixes:**
- Fixed variable comparison bug in `Setup-Git.psm1` (line 91): was comparing `$remote -ne $remote` instead of `$remote -ne $local`
- Fixed function name typo in `GitTabExpansion.psm1` (line 185): `gitRemoteTagss` → `gitRemoteTags`

**Code Quality Enhancements:**
- Added `[CmdletBinding()]` attributes to all functions for better PowerShell integration
- Added parameter validation with `[ValidateScript()]` attributes where applicable
- Improved error handling with try-finally blocks in `Check-RemoteRepository`
- Rewrote `Get-Editor` function to use `Get-Command` instead of wildcard patterns for safer path resolution
- Optimized module loading with explicit `-Filter '*.psm1' -File` parameters
- Fixed deprecated PowerShell syntax (`-verbose:$false` → `-Verbose:$false`)
- Improved `ConvertTo-PlainText` to properly clean up secure string pointers
- Enhanced `Create-Console` with proper error checking for ConEmu availability

**Performance Improvements:**
- Implemented **asynchronous git fetch** using PowerShell background jobs (`Start-Job`) to eliminate startup blocking
- `Show-GitRepoSyncHints` now accepts `-SkipFetch` parameter to skip fetch on startup
- New `Start-AsyncGitFetch` function spawns background fetch job that doesn't delay shell initialization
- Startup now immediately displays sync status while fetch completes in background

**Documentation:**
- Updated CLAUDE.md to reflect current implementation
- Added documentation for async git fetch functions and behavior
- All functions now follow PowerShell best practices

## Repository Overview

This is a Windows PowerShell profile repository that provides a customized shell environment with Git integration, enhanced prompts, and utility functions. The repository is designed to be cloned to `$env:USERPROFILE\Documents\Powershell` and contains the main PowerShell profile along with supporting modules and scripts.

## Key Architecture

### Profile Loading System

The main entry point is `Microsoft.PowerShell_profile.ps1`, which:
1. Automatically loads all `.psm1` module files from the root directory via `Get-ChildItem` and `Import-Module`
2. Adds `$env:USERPROFILE\.local\bin` and the local `Scripts/` folder to PATH
3. Sets up a custom prompt that displays the current directory name and Git branch (if in a repo)
4. Runs `Show-GitRepoSyncHints` at startup to check for uncommitted changes, unpushed commits, or remote updates

### Module System

Modules (`.psm1` files) in the root directory are automatically loaded:

- **GitTabExpansion.psm1**: Provides intelligent tab completion for Git commands, branches, remotes, stashes, and file paths. Supports custom Git aliases and tortoisegit commands.
- **Setup-Git.psm1**: Contains `Setup-Git` function to configure global Git settings, aliases, and user info. Also provides Git utility functions like `Test-GitRepository`, `Get-GitBranch`, and `Check-RemoteRepository`.
- **Setup-Utils.psm1**: General utility functions including `Get-Editor`, `Test-Syntax`, `Reload-Profile`, `Get-LocalOrParentPath`, and the `??` (Coalesce-Args) operator.

### Git Integration

The profile includes comprehensive Git integration:

- Custom prompt displays Git branch with colored brackets when in a repository
- `Show-GitRepoSyncHints` function checks repo status at startup and displays warnings for:
  - Uncommitted changes
  - Missing upstream branch configuration
  - Commits that need to be pulled (behind remote)
  - Commits that need to be pushed (ahead of remote)
- Extensive tab completion for Git commands via `GitTabExpansion` function
- Pre-configured Git aliases (run `git alias` to see all):
  - Branch management: `dlb` (delete local branch), `drb` (delete remote branch), `db` (delete both), `ct` (checkout tracking)
  - Shortcuts: `co` (checkout), `cb` (checkout -b), `ci` (commit -m), `ca` (add all + commit)
  - Logging: `ls` (last 10 commits), `ll` (full log), `lg` (graph view)

### Startup Behavior

On profile load, the system:
1. Checks sync status immediately and displays actionable hints if the repo is dirty or out-of-sync
2. Starts **asynchronous** `git fetch` in background job (non-blocking) to update remote tracking
3. Sets up posh-git and posh-docker modules if available
4. Configures Docker environment variables (`COMPOSE_CONVERT_WINDOWS_PATHS=1`, `DOCKER_BUILDKIT=1`)

**Note on Async Fetch:** The `git fetch` operation now runs in a background PowerShell job and does not block shell startup. This eliminates startup delays on slow networks while still updating remote tracking information. The `git fetch` can be disabled by setting `$env:PROFILE_GIT_FETCH=0`.

### Custom Functions

- **`l` / `ll`**: Human-friendly directory listing with color-coded output (directories in cyan, executables in green), file sizes in KB, and ISO timestamps. Designed to replace basic `ls` with more readable output.

## Development Commands

### Profile Management

```powershell
# Reload the PowerShell profile after making changes
Reload-Profile

# Test PowerShell script syntax before running
Test-Syntax -Path <script.ps1>
```

### Git Configuration

```powershell
# Run initial Git setup (configures user, editor, aliases, merge tools)
Setup-Git

# View all configured Git aliases
git alias

# Display Git aliases in formatted table
Display-GitAliases
```

### Git Status and Sync

```powershell
# Manually check repo sync status with sync hints
Show-GitRepoSyncHints

# Manually start async git fetch in background
Start-AsyncGitFetch

# Manually check sync status without fetching
Show-GitRepoSyncHints -SkipFetch
```

**Functions:**
- `Show-GitRepoSyncHints [-RepoPath <path>] [-SkipFetch]` - Displays repo sync status (branch, dirty state, commits ahead/behind)
- `Start-AsyncGitFetch [-RepoPath <path>]` - Spawns background job to fetch without blocking

### Repository Maintenance

The profile repository itself should be kept in sync:
- The startup script will notify you of uncommitted changes or sync issues
- Use standard Git commands to commit and push changes
- Main branch is `master`

## Important Notes

### Path Configuration

- All PATH additions use `$env:USERPROFILE` to remain username-independent
- The `Scripts/` directory is automatically added to PATH if it exists
- The profile assumes this repository is located at `$env:USERPROFILE\Documents\Powershell`

### Git Aliases and Tab Completion

- Custom Git aliases (defined in `Setup-Git.psm1`) are recognized by tab completion
- Tab completion supports local branches, remote branches, stashes, and file paths
- The `GitTabExpansion` function intercepts standard PowerShell tab completion for Git commands

### Module Auto-Loading

When adding new utility functions, place them in a `.psm1` file in the root directory and they will be automatically loaded on profile startup. Use `Export-ModuleMember` to control which functions/aliases are exported.

### Startup Performance

The `Show-GitRepoSyncHints` function runs a `git fetch` by default, which can add startup latency. Set `$env:PROFILE_GIT_FETCH=0` to disable fetching and speed up shell startup.

## Configuration Reference

### Multi-Account Git Configuration

This repository uses a **machine-independent** git configuration strategy that automatically switches between personal and work identities based on repository remotes.

#### Architecture

**Three-file configuration system:**

1. **`~/.gitconfig`** - Main config with shared settings (aliases, tools, behavior) and conditional includes
2. **`~/.gitconfig-personal`** - Personal identity and URL rewriting
3. **`~/.gitconfig-work`** - Work identity and URL rewriting
4. **`~/.ssh/config`** - Machine-specific SSH key assignments

#### How It Works

**Automatic Identity Switching (Remote-Based):**

The main `~/.gitconfig` uses `[includeIf "hasconfig:remote.*.url:..."]` patterns to load the appropriate identity config based on the repository's remote URL:

- **Personal repos** (ilude, traefikturkey) → loads `~/.gitconfig-personal`
- **Work repos** (mtg-eagletg, EagleTG-Development) → loads `~/.gitconfig-work`

**Machine-Specific SSH Key Handling:**

SSH keys are configured per-machine in `~/.ssh/config` using host aliases:

```ssh
# Host aliases (same on all machines)
Host github.com-personal
  HostName github.com
  User git
  IdentityFile <machine-specific-path>
  IdentitiesOnly yes

Host github.com-work
  HostName github.com
  User git
  IdentityFile <machine-specific-path>
  IdentitiesOnly yes
```

**Windows machine (this machine):**
```ssh
Host github.com-personal
  IdentityFile ~/.ssh/id_ed25519-personal  # Personal key

Host github.com-work
  IdentityFile ~/.ssh/id_ed25519           # Work key
```

**Other machines (Linux/Mac):**
```ssh
Host github.com-personal
  IdentityFile ~/.ssh/id_ed25519           # Personal key

Host github.com-work
  IdentityFile ~/.ssh/id_ed25519-work      # Work key
```

#### Configuration Files

**`~/.gitconfig-personal`:**
```ini
# Personal repos configuration
[user]
	name = mike
	email = mglenn@ilude.com

[url "github.com-personal:"]
	insteadOf = git@github.com:
	insteadOf = https://github.com/
```

**`~/.gitconfig-work`:**
```ini
# Work repos configuration
[user]
	name = Mike Glenn
	email = michael.glenn@eagletg.com

[url "github.com-work:"]
	insteadOf = git@github.com:
	insteadOf = https://github.com/
```

#### Setup Instructions for New Machines

When setting up a new machine, follow these steps:

1. **Copy git config files** (same on all machines):
   ```bash
   # Main config with conditional includes and aliases
   cp ~/.gitconfig ~/.gitconfig.backup  # if it exists

   # Copy from dotfiles repo or this documentation
   # Files: ~/.gitconfig, ~/.gitconfig-personal, ~/.gitconfig-work
   ```

2. **Configure SSH keys** (machine-specific):
   ```bash
   # Edit ~/.ssh/config to add host aliases
   # Set IdentityFile paths based on which key is personal vs work

   # Windows: id_ed25519 = work, id_ed25519-personal = personal
   # Linux/Mac: id_ed25519 = personal, id_ed25519-work = work
   ```

3. **Verify setup**:
   ```bash
   # Clone a personal repo and check identity
   git clone git@github.com:ilude/test-repo.git
   cd test-repo
   git config user.email  # Should show: mglenn@ilude.com

   # Clone a work repo and check identity
   git clone git@github.com:mtg-eagletg/test-repo.git
   cd test-repo
   git config user.email  # Should show: michael.glenn@eagletg.com
   ```

#### Key Benefits

- **Automatic switching** - No manual configuration per repo
- **Machine-independent** - Same git config files work on all machines
- **Works anywhere** - Not dependent on directory structure
- **Simple SSH config** - Just update key paths per machine

#### Reference

Based on dotfiles repo: https://github.com/ilude/dotfiles

### Environment Variables

#### PROFILE_GIT_FETCH
- **Default:** 1 (enabled)
- **Purpose:** Controls whether `git fetch` runs automatically on shell startup
- **Values:**
  - `0` or `'false'` - Disable git fetch (faster startup)
  - Any other value - Enable git fetch (default)
- **Usage:** `$env:PROFILE_GIT_FETCH = 0`
- **When to Use:** Set to 0 for faster startup when working offline or on slow networks

#### COMPOSE_CONVERT_WINDOWS_PATHS
- **Default:** 1 (enabled)
- **Purpose:** Enables Docker Compose path conversion from Windows to WSL
- **Why:** Required for Docker Desktop on Windows with WSL2 backend
- **Usage:** Already set in profile, no action needed
- **Related:** Requires WSL2 and Docker Desktop

#### DOCKER_BUILDKIT
- **Default:** 1 (enabled)
- **Purpose:** Uses newer, faster Docker build engine with better caching
- **Benefits:**
  - Faster builds with improved caching strategies
  - Better error messages and build output
  - Improved build performance
- **Usage:** Already set in profile, no action needed
- **Requirements:** Docker version 18.09 or later

### Quick Reference

```powershell
# Disable git fetch for faster startup
$env:PROFILE_GIT_FETCH = 0

# Re-enable git fetch
$env:PROFILE_GIT_FETCH = 1

# Check current settings
$env:PROFILE_GIT_FETCH
$env:COMPOSE_CONVERT_WINDOWS_PATHS
$env:DOCKER_BUILDKIT
```

## Docker Utilities

### Docker Functions and Aliases

The profile includes comprehensive Docker utilities in `Setup/Setup-Docker.psm1`:

**Container Management:**
- `dbash <container>` - Execute bash shell in container
- `dps` - List running containers with details
- `dpsp` - List running containers with port information
- `dpa` - List all containers (including stopped)
- `dex <container> <command>` - Execute command in running container
- `dl` - Get latest container ID
- `drm` - Delete all stopped containers
- `dri` - Delete all unused images

**Image Management:**
- `db [tag] [path]` - Build Docker image (default: latest, current dir)
- `di` - List all Docker images
- `dip <container>` - Get container IP address

**Container Execution:**
- `dkd <args>` - Run daemonized container
- `dki <args>` - Run interactive container with bash
- `dc` - Docker compose alias (maps to `docker compose`)

**Error Handling:**
All Docker functions now include:
- Parameter validation with helpful error messages
- Container existence checks before operations
- Try-catch blocks for graceful error handling
- Verbose output support for troubleshooting

## Unix Utilities

### Unix-like Commands

The profile includes Unix compatibility functions in `Setup/Setup-Unix.psm1`:

**Network Utilities:**
- `Get-NetworkStatistics [-Protocol {TCP|UDP}]` - Display network connections
- `listen` - Alias for Get-NetworkStatistics

**Command Discovery:**
- `which <command>` - Show full path to command

**Features:**
- Handles IPv4 and IPv6 addresses
- Shows process names and PIDs
- Filters by TCP/UDP protocol
- Safe error handling for permission issues
- Returns N/A for inaccessible processes

### Directory Listing

The `l` function provides human-friendly directory listing:

```powershell
l              # List current directory
l "C:\path"    # List specific directory
ll             # Alias for l

# Features:
# - Directories shown in cyan
# - Executable files shown in green
# - File sizes in KB
# - ISO-formatted timestamps
# - Sorted: directories first, then by name
```

## PATH Management

The profile manages PATH intelligently with the `Add-PathIfNotExists` helper function:

- Automatically adds `$env:USERPROFILE\.local\bin` for user scripts
- Adds `Scripts/` directory from profile location
- Adds Windows PowerShell system directory
- Prevents duplicate entries
- Verbose output available with `-Verbose` flag

```powershell
# Manual PATH manipulation (if needed):
Add-PathIfNotExists -PathToAdd "C:\custom\path"
```
