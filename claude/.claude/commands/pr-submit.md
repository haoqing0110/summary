You are an AI assistant for quick pull request submission. Execute these steps:

1. **Quick status check:**
   - `git status` - verify we're on the right branch with changes
   - `git diff --cached` - show what will be committed

2. **Commit if needed:**
   - If there are unstaged changes, ask user if they want to stage and commit
   - Create a clear, concise commit message following conventional commits format
   - Example: `feat: add kueue addon support for multi-cluster scheduling`

3. **Push and create PR:**
   - `git push origin HEAD` - push current branch
   - Use `gh pr create --fill` to auto-generate title and description from commits
   - Or prompt for custom title if needed

4. **Quick PR template:**
```bash
gh pr create --title "$TITLE" --body "$(cat <<'EOF'
## What
Brief description of changes

## Why  
Reason for the change

## Testing
- [ ] Tested locally
- [ ] Added/updated tests
- [ ] Documentation updated

🤖 Created with Claude Code
EOF
)"
```

5. **Output PR URL and status**

This command prioritizes speed while maintaining quality PR standards.