# Personal Claude Rules

These are hard rules that apply to this repository and override any default behavior.

## Git Commit Rule (CRITICAL)

**RULE: Never git commit until explicitly asked**

- Do NOT automatically commit changes under any circumstances
- Wait for explicit user request: "commit this" or "make a commit"
- This applies even if there are staged changes or obvious fix-ups
- No assumptions about automation - always wait for the ask

**Rationale**: Gives the user complete control over when and what gets committed. Allows for review, testing, and batching of changes before committing.

**Examples:**
- ✅ DO: Make code changes, describe them, wait for user to ask for commit
- ✅ DO: Ask if user wants to commit if appropriate
- ❌ DON'T: Automatically run `git add` and `git commit` after making changes
- ❌ DON'T: Use pre-commit hooks to auto-commit
- ❌ DON'T: Assume user wants changes committed

---

## Documentation Organization Rule

**RULE: Use dated feature directories for documentation**

- New feature work: Create `.claude/features/YYYY-MM-DD_feature-name/` directories
- Document all work in these directories, not root
- Use date stamps for chronological organization
- Pattern: `.claude/features/2025-11-02_feature-description/`

**Examples:**
- ✅ `.claude/features/2025-11-02_initial-code-review/`
- ✅ `.claude/features/2025-11-02_phase-1-quick-wins/`
- ✅ `.claude/features/2025-11-03_new-feature/`

---

## Planning and Feature Requests Workflow

**RULE: Use @plan for feature planning, then ExitPlanMode when ready to code**

### When Starting Planning Mode

1. **User Request**: "I want to [feature description]" or explicitly uses `@plan`
2. **Claude Action**: Trigger planning mode to break down the task
3. **Claude Output**: Create a detailed plan with:
   - Clear implementation steps
   - Architectural decisions needed
   - Ambiguities to clarify
   - Estimated effort and complexity
4. **User Review**: User approves plan or requests changes

### Planning Mode Best Practices

- **Break down complex tasks** into manageable steps
- **Identify decisions needed** before implementation
- **Ask clarifying questions** about ambiguous requirements using `AskUserQuestion` tool
- **Propose approach** but let user decide implementation path
- **Document assumptions** clearly

### Exiting Planning Mode

When plan is approved:
1. **User says** "proceed" or "yes" or similar approval
2. **Claude uses** `ExitPlanMode` tool with the finalized plan
3. **Claude then** starts implementation based on approved plan
4. **Create feature directory**: `.claude/features/YYYY-MM-DD_feature-name/`
5. **Document progress** as implementation proceeds

### Feature Request Examples

**Example 1: Simple Bug Fix**
```
User: "Fix the network statistics function to handle permission errors"
Claude: No planning needed - small, clear scope
Claude: Goes directly to implementation
```

**Example 2: Medium Feature**
```
User: "@plan I want to add logging to the profile startup"
Claude: [Uses planning mode, proposes approach]
Claude: Asks about log location, verbosity levels, format
User: "I like option 2, use JSON format to $env:USERPROFILE/.local/logs"
Claude: [Uses ExitPlanMode]
Claude: [Implements logging feature]
```

**Example 3: Complex Feature**
```
User: "@plan Add caching to Git operations for faster startup"
Claude: [Uses planning mode, proposes architecture with cache invalidation]
Claude: Asks about cache storage, TTL, fallback behavior
User: "Proceed with 5-second TTL and file-based cache"
Claude: [Uses ExitPlanMode]
Claude: [Implements caching system]
```

### Feature Documentation

After implementation:
1. **Create feature directory**: `.claude/features/YYYY-MM-DD_feature-name/`
2. **Document what was done**: Include implementation summary
3. **Add to CLAUDE.md**: Reference new features if they affect usage
4. **Create completion summary**: What was built, testing performed, etc.
5. **List files changed**: For user review before committing

---

## Additional Guidelines

### Avoid Obsidian Integration
- Do NOT use Obsidian tools unless explicitly requested
- Use standard file operations instead
- User prefers direct file management

### PowerShell Best Practices
- All functions should have `[CmdletBinding()]` attribute
- All parameters should have validation
- Implement error handling with try-catch blocks
- Follow DRY principle (Don't Repeat Yourself)
- Maintain 100% backward compatibility

---

## Review Checklist

Before completing work:
- [ ] No git commits made (unless explicitly asked)
- [ ] All changes documented
- [ ] PowerShell best practices followed
- [ ] Error handling implemented
- [ ] Backward compatibility maintained
- [ ] CLAUDE.md updated if needed

---

**Last Updated**: 2025-11-02
