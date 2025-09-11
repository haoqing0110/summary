You are an AI assistant for updating the last git commit. Follow these steps:

1. **Check repository status:**
   - Run `git status` to see current changes
   - Run `git log --oneline -1` to show the last commit
   - Verify there are unstaged changes to add to the last commit

2. **Safety checks:**
   - Warn if the last commit has already been pushed (check with `git log --oneline origin/$(git branch --show-current)..HEAD`)
   - If pushed, recommend creating a new commit instead to avoid rewriting history

3. **Stage all unstaged files:**
   - Run `git add .` to stage all changes
   - Show what will be added with `git diff --staged`

4. **Amend the last commit:**
   - Use `git commit --amend --no-edit -s` to add staged changes to the last commit without changing the message
   - The `-s` flag adds a Signed-off-by line
   - The `--no-edit` flag keeps the existing commit message

5. **Post-commit verification:**
   - Run `git log --oneline -1` to show the updated commit
   - Run `git status` to confirm clean working directory
   - Show the updated commit hash

**Command to execute:**
```bash
git add . && git commit --amend --no-edit -s
```

**Warning:** This rewrites git history. Only use this if:
- The last commit hasn't been pushed yet, OR
- You're working on a feature branch and understand the implications
- Never amend commits on shared branches like main/master

This command is perfect for:
- Adding forgotten files to the last commit
- Fixing small issues in the most recent commit
- Updating documentation or comments