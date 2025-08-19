# Usage Guide - Elixir Code Review Framework

This guide covers how to use the automated code review framework for day-to-day development.

## Quick Start

### Basic Review Commands

```bash
# Interactive PR selection
./scripts/review-pr.sh --interactive

# Review specific PR by name
./scripts/review-pr.sh --pr-name "Fix authentication bug"

# Dry run (show what would happen)
./scripts/review-pr.sh --pr-name "Test PR" --dry-run

# Verbose output for debugging
./scripts/review-pr.sh --pr-name "Test PR" --verbose
```

## Command Line Options

| Option | Description | Example |
|--------|-------------|----------|
| `--pr-name NAME` | Review specific PR by name | `--pr-name "Bug fix"` |
| `--interactive` | Select from list of open PRs | `--interactive` |
| `--config PATH` | Use custom config directory | `--config ./custom-config` |
| `--dry-run` | Show analysis without creating comments | `--dry-run` |
| `--verbose` | Detailed output and logging | `--verbose` |
| `--help` | Show help message | `--help` |

## Review Workflow

### 1. Preparation Phase

Before running a review:

```bash
# Ensure your config is up to date
cat config/repositories.yaml

# Check available patterns
ls patterns/*/

# Verify MCP servers are working
superclaude "Test GitHub MCP by listing my repositories"
```

### 2. Analysis Phase

The framework performs multi-stage analysis:

1. **Fetch PR Data**: Gets diff, changed files, and metadata
2. **Pattern Matching**: Applies detection rules from pattern library
3. **Sequential Analysis**: Deep reasoning for complex architectural issues
4. **Issue Categorization**: Groups and prioritizes findings
5. **Comment Generation**: Creates targeted, actionable feedback

### 3. Review Phase

Review the generated analysis:

```bash
# Example output during analysis
[INFO] Starting code review for PR: Fix authentication bug
[INFO] Analyzing PR with sequential thinking and pattern detection...
[INFO] Found 3 critical issues, 5 high priority issues
[SUCCESS] Analysis complete! Results saved to /tmp/analysis_results.json
```

## Understanding Results

### Issue Severity Levels

| Severity | Description | Action Required |
|----------|-------------|------------------|
| 🚨 **Critical** | Security vulnerabilities, data leaks | Must fix before merge |
| ⚠️ **High** | Code quality, breaking changes | Should fix before merge |
| 🔵 **Medium** | Refactoring opportunities | Consider fixing |
| 🟢 **Low** | Style suggestions | Optional improvements |

### Category Types

- **Architectural**: System-wide patterns affecting multiple components
- **File-level**: Issues within individual modules or files
- **One-liners**: Simple fixes requiring minimal changes
- **Integrations**: Third-party library usage patterns

### Sample Output

```json
{
  "pr_name": "Fix authentication bug",
  "total_issues": 8,
  "issues": [
    {
      "pattern": "manual-authorization-bypass",
      "severity": "critical",
      "category": "architectural",
      "file": "lib/auth/permissions.ex",
      "line": 45,
      "description": "Manual role checking bypassing Bodyguard policies",
      "time_minutes": 45,
      "breaking_change_risk": "medium"
    }
  ],
  "summary": {
    "critical": 1,
    "high": 2,
    "medium": 3,
    "low": 2,
    "total_time_hours": 2.5,
    "estimated_cost_savings": 2250
  }
}
```

## Advanced Usage

### Custom Configuration

```bash
# Use custom config for different projects
./scripts/review-pr.sh --config ./project-specific-config --pr-name "PR Name"

# Override severity thresholds
# Edit config/severity-levels.yaml to customize
```

### Batch Processing

```bash
# Review multiple PRs (script example)
for pr in "PR 1" "PR 2" "PR 3"; do
  ./scripts/review-pr.sh --pr-name "$pr" --dry-run
done
```

### Integration with CI/CD

```yaml
# GitHub Actions example
name: Automated Code Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  code-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Code Review
        run: |
          git clone https://github.com/VMWepinion/elixir-code-review.git
          cd elixir-code-review
          ./scripts/install.sh
      - name: Run Review
        run: |
          cd elixir-code-review
          ./scripts/review-pr.sh --pr-name "${{ github.event.pull_request.title }}"
```

## Pattern-Specific Usage

### Security Patterns

For security-focused reviews:

```bash
# Focus on critical security patterns
./scripts/review-pr.sh --pr-name "Security fix" --config security-focused-config
```

The framework will prioritize:
- Manual authorization bypasses
- PubSub data leaks
- Authentication vulnerabilities
- Data exposure risks

### Integration Patterns

For library integration reviews:

```bash
# Focus on specific integration patterns
# Configure patterns/integrations/ directory with relevant patterns
```

Common integration reviews:
- **Ecto**: Schema, migration, and query patterns
- **Phoenix**: Controller, view, and PubSub patterns
- **Bodyguard**: Authorization and policy patterns
- **Mock**: Testing and mocking patterns

## Interpreting GitHub Comments

### Critical Issue Example

```markdown
🚨 **CRITICAL** Anti-pattern detected: Manual Authorization Bypass

**Issue**: Custom authorization logic bypassing established Bodyguard patterns

**Location**: `lib/auth/permissions.ex:45`

**Problem**:
```elixir
def can_access?(user, resource) do
  user.role == "admin" || user.id == resource.owner_id
end
```

**Required Fix**:
```elixir
case Bodyguard.permit(ResourcePolicy, :access, user, resource) do
  :ok -> true
  {:error, _} -> false
end
```

**Time Estimate**: ~45 minutes to fix
**Breaking Change Risk**: medium

⚠️ **BLOCKING**: This issue must be resolved before merge.
```

### Summary Comment Example

```markdown
## 🤖 Automated Code Review Summary

**Total Issues Found**: 8
**Estimated Fix Time**: 2.5 hours
**Estimated Cost Savings**: $2,250

### Issues by Severity:
- 🚨 **Critical**: 1 (must fix before merge)
- ⚠️ **High**: 2
- 🔵 **Medium**: 3
- 🟢 **Low**: 2

### Quick Wins (< 10 min each):
- Fix variable naming in user_controller.ex:23
- Remove unused import in circle.ex:5

**Next Steps**:
1. Address critical security issues first
2. Focus on high-priority items
3. Batch similar issues for efficiency
```

## Best Practices

### 1. Review Strategy

- **Start with Critical**: Always address security issues first
- **Batch Similar Issues**: Group related problems for efficient fixing
- **Use Dry Run**: Test analysis before creating actual comments
- **Regular Updates**: Keep pattern library current with team learnings

### 2. Team Integration

- **Shared Config**: Use consistent configuration across team
- **Pattern Contributions**: Add team-specific patterns to the library
- **Review Metrics**: Track time savings and issue resolution rates

### 3. Continuous Improvement

- **Pattern Refinement**: Update detection rules based on false positives
- **New Patterns**: Add patterns for newly discovered anti-patterns
- **Feedback Loop**: Incorporate team feedback into pattern descriptions

## Troubleshooting

### Common Issues

**No issues found in obviously problematic code**
- Check pattern files are properly formatted
- Verify detection rules match the code structure
- Test with `--verbose` to see detailed analysis

**Too many false positives**
- Refine regex patterns in detection rules
- Add exclusion patterns to config
- Improve semantic analysis prompts

**GitHub comments not appearing**
- Check GitHub MCP server authentication
- Verify repository permissions
- Test with `--dry-run` first

**Analysis taking too long**
- Limit file patterns in configuration
- Focus on specific pattern categories
- Use smaller PR sizes for testing

## Performance Tips

- **Targeted Patterns**: Only enable patterns relevant to your codebase
- **File Filtering**: Use specific file patterns to reduce analysis scope
- **Incremental Reviews**: Focus on changed files only
- **Parallel Analysis**: The framework supports concurrent pattern detection

## Next Steps

1. **Learn Architecture**: [docs/architecture.md](architecture.md)
2. **Add Custom Patterns**: [docs/adding-patterns.md](adding-patterns.md)
3. **View Examples**: [docs/examples/](examples/)
4. **Customize Templates**: Edit `config/github-templates.yaml`

---

*Last updated: 2025-08-19*