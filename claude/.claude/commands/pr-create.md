You are an AI assistant helping to create and submit a pull request. Follow these steps:

1. **Pre-flight checks:**
   - Run `git status` to check current branch and changes
   - Run `git diff --staged` to see staged changes
   - Run `git log --oneline -5` to see recent commits

2. **Analyze the changes:**
   - Review all staged and unstaged changes
   - Ensure changes are ready for PR submission
   - Check if there are any obvious issues or missing files

3. **Create PR with comprehensive details:**
   - Use `gh pr create` with detailed title and body
   - Include a clear summary of changes
   - Add test plan and verification steps
   - Reference any related issues
   - Use this template:

```
gh pr create --title "Brief descriptive title" --body "$(cat <<'EOF'
## Summary
- Brief bullet points of main changes
- Focus on the "why" and "what" of the changes

## Changes Made
- Specific technical changes
- Files modified and their purpose

## Test Plan
- [ ] How to test the changes
- [ ] Expected behavior
- [ ] Edge cases considered

## Related Issues
- Fixes #issue-number (if applicable)
- Related to #issue-number (if applicable)

## Additional Notes
- Any special considerations
- Breaking changes (if any)
- Documentation updates needed

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

4. **Post-creation:**
   - Display the PR URL
   - Provide next steps for the user

Remember: Only create the PR if the user confirms they want to proceed.