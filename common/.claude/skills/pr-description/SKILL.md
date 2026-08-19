---
name: pr-description
description: Generate a pull request description for the current branch. Use when the user asks to "write a PR description", "generate PR description", "create PR description", "describe this PR", or "summarize changes for PR".
---

# PR Description Generator

Generate a well-structured pull request description based on the current branch's changes.

## When This Skill Applies

When the user wants a PR description written for their current branch before or instead of creating a full PR.

## Instructions

1. Determine the base branch by checking the repo's default branch (usually `main` or `master`).
2. Run these commands to understand the full scope of changes:
   - `git log --oneline <base>..HEAD` to see all commits on this branch
   - `git diff <base>...HEAD --stat` for a file-level summary
   - `git diff <base>...HEAD` for the full diff
3. Read any relevant files if the diff alone doesn't make the intent clear.
4. Write a PR description in this format:

```markdown
## Summary

1-3 sentences explaining what this PR does and why.

## Changes

- Bulleted list of meaningful changes grouped logically
- Focus on *what* changed and *why*, not line-by-line diffs
- Mention new dependencies, migrations, or config changes if any

## Test plan

- [ ] How to verify these changes work correctly
- [ ] Edge cases or areas to pay attention to during review
```

5. Output the description as markdown so the user can copy it or use it with `gh pr create`.

## Guidelines

- Keep the summary concise — lead with the "why".
- Group related changes together rather than listing every file.
- Call out breaking changes, new environment variables, or required migrations prominently.
- If the branch has a single commit, the description can be shorter.
- If the branch has many commits, synthesize rather than listing each one.
- Do not invent changes — only describe what the diff shows.
