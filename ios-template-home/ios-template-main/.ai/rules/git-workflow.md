# Git Workflow - iOS Template Project

## Branch Strategy

### Main Branches
```
main (production)
  ↑
develop (integration)
  ↑
feature/* (features)
bugfix/* (bugs)
hotfix/* (critical fixes)
release/* (release preparation)
```

### Branch Naming
```bash
# Features
feature/add-login-screen
feature/implement-tca-auth
feature/setup-firebase-analytics

# Bug fixes
bugfix/fix-memory-leak-in-image-cache
bugfix/resolve-crash-on-logout

# Hotfixes (từ main)
hotfix/critical-payment-issue
hotfix/security-patch-v1.2.1

# Releases
release/v1.0.0
release/v1.1.0-beta
```

## Commit Message Convention

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: Tính năng mới
- **fix**: Sửa bug
- **docs**: Thay đổi documentation
- **style**: Format code (không ảnh hưởng logic)
- **refactor**: Refactor code
- **perf**: Cải thiện performance
- **test**: Thêm hoặc sửa tests
- **chore**: Changes to build process, tools
- **ci**: Changes to CI configuration

### Examples

```bash
# Feature
feat(auth): implement biometric login
- Add FaceID/TouchID support
- Integrate LocalAuthentication framework
- Add fallback to passcode
- Update settings UI

# Bug fix
fix(network): resolve token refresh race condition
- Add mutex lock for token refresh
- Cancel pending requests during refresh
- Add retry logic after token update

Closes #123

# Documentation
docs(readme): update setup instructions
- Add SPM installation steps
- Include troubleshooting section
- Update dependency versions

# Refactor
refactor(tca): simplify reducer composition
- Extract child reducers
- Remove duplicate code
- Improve readability

# Performance
perf(image): optimize image loading and caching
- Implement progressive loading
- Add memory cache limits
- Use lazy loading for lists

# Test
test(auth): add unit tests for login reducer
- Test success case
- Test error handling
- Test token refresh
- Add mock services

# Chore
chore(deps): update dependencies to latest versions
- TCA 1.5.0 → 1.6.0
- Kingfisher 7.10.0 → 7.11.0
- Swinject 2.8.3 → 2.8.4
```

## Workflow Steps

### 1. Bắt đầu Feature Mới
```bash
# Update develop branch
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/add-user-profile

# Work on feature...
git add .
git commit -m "feat(profile): add user profile view"

# Push to remote
git push -u origin feature/add-user-profile
```

### 2. Keep Branch Updated
```bash
# Regularly sync with develop
git checkout develop
git pull origin develop

git checkout feature/add-user-profile
git rebase develop

# Or merge if rebase conflicts are complex
git merge develop
```

### 3. Code Review & PR
```bash
# Ensure all tests pass
swift test

# Lint code
swiftlint lint --strict

# Push final changes
git push origin feature/add-user-profile

# Create PR on GitHub
# - Title: Clear, descriptive
# - Description: What, why, how
# - Link related issues
# - Add reviewers
# - Add labels
```

### 4. After PR Approved
```bash
# Squash and merge (preferred)
# or Merge commit
# or Rebase and merge

# Delete feature branch
git branch -d feature/add-user-profile
git push origin --delete feature/add-user-profile
```

### 5. Hotfix Process
```bash
# Start from main
git checkout main
git pull origin main

# Create hotfix branch
git checkout -b hotfix/fix-payment-crash

# Fix the issue
git add .
git commit -m "hotfix(payment): fix crash when processing payment"

# Merge to main
git checkout main
git merge hotfix/fix-payment-crash
git tag v1.0.1
git push origin main --tags

# Also merge to develop
git checkout develop
git merge hotfix/fix-payment-crash
git push origin develop

# Delete hotfix branch
git branch -d hotfix/fix-payment-crash
```

## Pull Request Template

```markdown
## Description
<!-- Mô tả rõ ràng PR này làm gì -->

## Type of Change
- [ ] Feature (tính năng mới)
- [ ] Bug fix (sửa lỗi)
- [ ] Refactor (cải thiện code)
- [ ] Documentation (tài liệu)
- [ ] Performance (tối ưu)

## Related Issues
Closes #[issue_number]

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Unit tests added/updated
- [ ] UI tests added/updated (if applicable)
- [ ] Manual testing completed
- [ ] Tested on iPhone SE, iPhone 15 Pro Max
- [ ] Tested dark/light mode
- [ ] Tested with Dynamic Type

## Screenshots (if applicable)
<!-- Add screenshots here -->

## Checklist
- [ ] Code follows project conventions
- [ ] SwiftLint passes with no warnings
- [ ] All tests pass
- [ ] Documentation updated
- [ ] No sensitive data in code
- [ ] Performance impact considered
- [ ] Accessibility verified

## Additional Notes
<!-- Any additional context -->
```

## Git Rules

### DO ✅
- Commit often with meaningful messages
- Write descriptive commit messages
- Keep commits atomic (one logical change)
- Review your own diff before pushing
- Update documentation in same commit
- Use Vietnamese for commit messages
- Reference issue numbers

### DON'T ❌
- Commit directly to main
- Push incomplete features
- Mix multiple changes in one commit
- Use generic messages ("update", "fix")
- Commit sensitive data (keys, tokens)
- Force push to shared branches
- Leave commented-out code

## Git Hooks (Optional)

### Pre-commit Hook
```bash
#!/bin/sh
# .git/hooks/pre-commit

# Run SwiftLint
if which swiftlint >/dev/null; then
    swiftlint lint --strict
    if [ $? -ne 0 ]; then
        echo "SwiftLint failed. Please fix the issues."
        exit 1
    fi
fi

# Run tests
swift test
if [ $? -ne 0 ]; then
    echo "Tests failed. Please fix before committing."
    exit 1
fi
```

### Commit-msg Hook
```bash
#!/bin/sh
# .git/hooks/commit-msg

commit_msg=$(cat "$1")

# Check commit message format
if ! echo "$commit_msg" | grep -qE "^(feat|fix|docs|style|refactor|perf|test|chore|ci)(\(.+\))?: .+"; then
    echo "Error: Commit message không đúng format"
    echo "Format: <type>(<scope>): <subject>"
    echo "Example: feat(auth): add biometric login"
    exit 1
fi
```

## Tags and Releases

### Semantic Versioning
```
MAJOR.MINOR.PATCH

Example:
v1.0.0 - Initial release
v1.0.1 - Hotfix
v1.1.0 - New feature
v2.0.0 - Breaking changes
```

### Creating Tags
```bash
# Annotated tag (recommended)
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# List tags
git tag -l

# Delete tag
git tag -d v1.0.0
git push origin --delete v1.0.0
```

## Useful Git Commands

```bash
# View commit history
git log --oneline --graph --decorate

# View changes
git diff
git diff --staged

# Stash changes
git stash
git stash pop
git stash list

# Interactive rebase (clean history)
git rebase -i HEAD~3

# Amend last commit
git commit --amend

# Cherry-pick commit
git cherry-pick <commit-hash>

# Find who changed a line
git blame <file>

# Bisect to find bug
git bisect start
git bisect bad
git bisect good <commit>
```

## Merge vs Rebase

### Use Merge When:
- Working on long-lived feature branches
- Want to preserve exact history
- Multiple people working on same branch

### Use Rebase When:
- Cleaning up local commits before PR
- Want linear history
- Working alone on feature branch

```bash
# Rebase example
git checkout feature/my-feature
git rebase develop

# If conflicts
# Fix conflicts
git add .
git rebase --continue

# Or abort
git rebase --abort
```

## Best Practices

1. **Commit Early, Commit Often**
   - Small, focused commits are better
   - Easier to review
   - Easier to revert if needed

2. **Write Good Commit Messages**
   - First line: summary (50 chars)
   - Blank line
   - Detailed explanation (72 chars per line)
   - Reference issues

3. **Review Before Pushing**
   - Use `git diff` to review changes
   - Check for debug code
   - Verify no sensitive data

4. **Keep Branches Short-Lived**
   - Feature branches < 1 week
   - Merge frequently
   - Avoid long-running branches

5. **Use .gitignore Properly**
   - Ignore build artifacts
   - Ignore IDE files
   - Ignore local config
   - Never commit sensitive files

## Emergency Procedures

### Accidentally Committed to Main
```bash
# Revert the commit
git revert <commit-hash>
git push origin main

# Or reset (if not pushed)
git reset --hard HEAD~1
```

### Need to Undo Last Commit (Not Pushed)
```bash
# Keep changes
git reset --soft HEAD~1

# Discard changes
git reset --hard HEAD~1
```

### Recover Deleted Branch
```bash
# Find the commit
git reflog

# Recreate branch
git checkout -b recovered-branch <commit-hash>
```

### Remove Sensitive Data
```bash
# Use BFG Repo-Cleaner
bfg --delete-files secret-file.txt
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```
