# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

**Documentation:**
- Updated CLAUDE.md to reflect current implementation
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
1. Optionally runs `git fetch` in the profile's own repository (controlled by `$env:PROFILE_GIT_FETCH`)
2. Checks sync status and displays actionable hints if the repo is dirty or out-of-sync
3. Sets up posh-git and posh-docker modules if available
4. Configures Docker environment variables (`COMPOSE_CONVERT_WINDOWS_PATHS=1`, `DOCKER_BUILDKIT=1`)

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
