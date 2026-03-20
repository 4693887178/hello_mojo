---
name: "code-reviewer"
description: "Reviews code for correctness, maintainability, and project standards. Invoke when user asks for code review, provides PR number/URL, or before merging changes."
---

# Code Reviewer

This skill guides the agent in conducting professional and thorough code reviews for both local development and remote Pull Requests.

## Workflow

### 1. Determine Review Target

- **Remote PR**: If the user provides a PR number or URL (e.g., "Review PR #123"), target that remote PR.
- **Local Changes**: If no specific PR is mentioned, or if the user asks to "review my changes", target the current local file system states (staged and unstaged changes).

### 2. Preparation

#### For Remote PRs

1. **Checkout**: Use the GitHub CLI to checkout the PR.
   ```bash
   gh pr checkout <PR_NUMBER>
   ```

2. **Preflight**: Execute the project's standard verification suite to catch automated failures early.
   ```bash
   npm run preflight
   ```

3. **Context**: Read the PR description and any existing comments to understand the goal and history.

#### For Local Changes

1. **Identify Changes**:
   - Check status: `git status`
   - Read diffs: `git diff` (working tree) and/or `git diff --staged` (staged)

2. **Preflight (Optional)**: If the changes are substantial, ask the user if they want to run `npm run preflight` before reviewing.

### 3. In-Depth Analysis

Analyze the code changes based on the following pillars:

| Pillar | Questions to Ask |
|--------|------------------|
| **Correctness** | Does the code achieve its stated purpose without bugs or logical errors? |
| **Maintainability** | Is the code clean, well-structured, and easy to understand and modify? Consider code clarity, modularity, and adherence to design patterns. |
| **Readability** | Is the code well-commented (where necessary) and consistently formatted according to project coding style? |
| **Efficiency** | Are there any obvious performance bottlenecks or resource inefficiencies? |
| **Security** | Are there any potential security vulnerabilities or insecure coding practices? |
| **Edge Cases** | Does the code appropriately handle edge cases and potential errors? |
| **Testability** | Is the new or modified code adequately covered by tests? Suggest additional test cases. |

### 4. Provide Feedback

#### Structure

```
## Summary
A high-level overview of the review.

## Findings

### Critical
- Bugs, security issues, or breaking changes

### Improvements
- Suggestions for better code quality or performance

### Nitpicks (optional)
- Formatting or minor style issues

## Conclusion
Clear recommendation: Approved / Request Changes
```

#### Tone

- Be constructive, professional, and friendly
- Explain **why** a change is requested
- For approvals, acknowledge the specific value of the contribution

### 5. Cleanup (Remote PRs only)

After the review, ask the user if they want to switch back to the default branch (e.g., `main` or `master`).

## Review Checklist

Use this checklist during reviews:

### Code Quality
- [ ] Code follows project style guidelines
- [ ] Functions and variables are appropriately named
- [ ] Code is DRY (Don't Repeat Yourself)
- [ ] No dead code or commented-out code blocks
- [ ] Appropriate use of comments

### Logic & Correctness
- [ ] Logic is correct and handles all cases
- [ ] No off-by-one errors or boundary issues
- [ ] Null/undefined checks where needed
- [ ] Error handling is appropriate

### Performance
- [ ] No obvious performance issues
- [ ] Efficient algorithms and data structures
- [ ] No unnecessary computations or memory allocations

### Security
- [ ] No hardcoded secrets or credentials
- [ ] Input validation where necessary
- [ ] No SQL injection, XSS, or other common vulnerabilities
- [ ] Proper authentication/authorization checks

### Testing
- [ ] Unit tests for new functionality
- [ ] Edge cases are tested
- [ ] Tests are meaningful and not just for coverage

### Documentation
- [ ] Public APIs are documented
- [ ] README updated if needed
- [ ] Changelog updated if needed

## Example Review

```markdown
## Summary
This PR adds a new caching layer to the user service. Overall, the implementation 
is solid and well-structured. A few improvements are suggested below.

## Findings

### Critical
- None identified

### Improvements
1. **cache_key generation** (user_service.py:45)
   Consider using a more robust key generation method to avoid collisions.
   ```python
   # Current
   cache_key = f"user:{user_id}"
   
   # Suggested
   cache_key = f"user:{user_id}:{hashlib.md5(str(user_id).encode()).hexdigest()[:8]}"
   ```

2. **Cache invalidation** (user_service.py:78)
   The cache isn't invalidated when user data changes. Consider adding:
   ```python
   def update_user(user_id, data):
       cache.delete(f"user:{user_id}")
       # ... rest of update logic
   ```

### Nitpicks
- Line 23: Extra blank line
- Line 56: Typo in comment "recieve" → "receive"

## Conclusion
**Request Changes** - Please address the cache invalidation concern before merging.
The improvement suggestions are optional but recommended.
```
