# Setup Guide - Elixir Code Review Framework

This guide will help you set up the automated code review framework using Claude and MCP servers.

## Prerequisites

### Required Software
1. **Claude Code CLI** - Latest version with MCP support
   ```bash
   # Install according to: https://docs.anthropic.com/en/docs/claude-code
   ```

2. **MCP Servers** - The following servers must be installed:
   - **GitHub MCP**: For repository and PR operations
   - **Sequential-thinking MCP**: For complex code analysis
   - **Browser MCP**: For documentation research (optional)

### Required Access
- GitHub access token with repo permissions
- Access to target repositories for review
- Claude Code properly authenticated

## Installation Steps

### 1. Clone the Repository
```bash
git clone https://github.com/VMWepinion/elixir-code-review.git
cd elixir-code-review
```

### 2. Run Installation Script
```bash
./scripts/install.sh
```

This script will:
- Check for Claude CLI and MCP servers
- Set up configuration files
- Make scripts executable
- Optionally create system-wide symlinks

### 3. Configure Repository Settings

Edit `config/repositories.yaml`:
```yaml
default_repository:
  owner: "YourOrg"
  name: "your-repo"
  branch: "main"
  
repositories:
  your_project:
    owner: "YourOrg"
    name: "your-repo"
    branch: "main"
    patterns:
      - "architectural/*"
      - "file-level/*"
      - "integrations/phoenix/*"
    file_patterns:
      - "*.ex"
      - "*.exs"
```

### 4. Verify MCP Server Configuration

Test that MCP servers are working:
```bash
superclaude <<EOF
Please test the following MCP servers:
1. List my GitHub notifications (GitHub MCP)
2. Use sequential thinking to analyze a simple problem (Sequential-thinking MCP)

This confirms the servers are properly configured.
EOF
```

## Configuration Files

### Repository Configuration (`config/repositories.yaml`)
- Target repositories and branches
- File patterns to analyze
- Pattern categories to apply
- Exclusion rules

### Severity Levels (`config/severity-levels.yaml`)
- Define issue priority levels
- Set time estimates by severity
- Configure merge blocking rules
- Cost calculation settings

### GitHub Templates (`config/github-templates.yaml`)
- PR comment templates
- Issue severity formatting
- Batching and grouping rules
- Summary report templates

## Verification

### Test Basic Functionality
```bash
# Test help system
./scripts/review-pr.sh --help

# Test configuration loading
./scripts/review-pr.sh --dry-run --verbose
```

### Test MCP Integration
```bash
# Test GitHub MCP
superclaude "List open PRs in the configured repository using GitHub MCP"

# Test sequential thinking
superclaude "Use sequential-thinking MCP to analyze this pattern: What are the key considerations for implementing automated code review?"
```

### Test Pattern Detection
```bash
# Run against a small test PR
./scripts/review-pr.sh --pr-name "Test PR" --dry-run
```

## Troubleshooting

### Common Issues

**"superclaude not found"**
- Install Claude Code CLI from official documentation
- Ensure it's in your PATH

**"GitHub MCP not responding"**
- Check MCP server installation
- Verify GitHub authentication in Claude settings
- Test with simple GitHub operations

**"Repository config not found"**
- Copy `config/repositories.yaml.example` to `config/repositories.yaml`
- Edit with your repository details

**"No patterns found"**
- Ensure pattern files exist in `patterns/` directory
- Check file permissions
- Verify YAML syntax in config files

### Debug Mode
```bash
# Enable verbose logging
./scripts/review-pr.sh --verbose --dry-run

# Check configuration
superclaude "Please validate the configuration files in the elixir-code-review project and identify any issues"
```

## Integration with Existing Workflow

### CI/CD Integration

Add to your GitHub Actions workflow:
```yaml
- name: Automated Code Review
  run: |
    git clone https://github.com/VMWepinion/elixir-code-review.git
    cd elixir-code-review
    ./scripts/review-pr.sh --pr-name "${{ github.event.pull_request.title }}"
```

### Local Development

Add to your project's development workflow:
```bash
# Before creating PR
review-pr --interactive

# As part of pre-commit hook
review-pr --pr-name "$(git log -1 --pretty=%B)" --dry-run
```

### VS Code Integration (Future)

The framework is designed to support IDE integration:
- Real-time pattern detection
- Inline suggestions
- Pattern documentation links

## Next Steps

1. **Read Usage Guide**: [docs/usage.md](usage.md)
2. **Understand Architecture**: [docs/architecture.md](architecture.md)
3. **Add Custom Patterns**: [docs/adding-patterns.md](adding-patterns.md)
4. **Run First Review**: `./scripts/review-pr.sh --interactive`

## Support

- **Issues**: Create issues in the GitHub repository
- **Documentation**: Check the `docs/` directory
- **Examples**: See `docs/examples/` for real-world usage

---

*Last updated: 2025-08-19*