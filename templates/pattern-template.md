---
title: "Pattern Name (e.g., Manual Authorization Bypass)"
severity: critical|high|medium|low  
category: architectural|file-level|one-liners|integrations
detection_method: regex|ast|semantic|hybrid
estimated_fix_time_minutes: number
breaking_change_risk: low|medium|high
tags: [bodyguard, authorization, security, phoenix, ecto]
version: "1.0"
created_date: "YYYY-MM-DD"
last_updated: "YYYY-MM-DD"
---

# Bad Behavior Description

Clear, concise description of what constitutes the anti-pattern. Explain:
- Why this is problematic
- Common scenarios where this occurs
- Impact on code quality, security, or performance

## Context

- **When it appears**: Specific situations or code contexts
- **Why developers do this**: Common motivations or misconceptions
- **Risk level**: Potential consequences

# Examples of Bad Behavior

```elixir
# ❌ BAD: Example of the anti-pattern
def bad_example() do
  # Show concrete example of what NOT to do
  # Include real-world scenarios when possible
end
```

```elixir
# ❌ BAD: Another variation of the same pattern
def another_bad_example(param) do
  # Multiple examples help cover edge cases
end
```

# Solutions

```elixir
# ✅ GOOD: Corrected version following best practices
def good_example() do
  # Show the proper way to handle this scenario
  # Explain why this approach is better
end
```

```elixir
# ✅ GOOD: Alternative solution approach
def alternative_solution(param) do
  # Sometimes multiple valid solutions exist
  # Show different approaches when applicable
end
```

# Detection Rules

## Regex Patterns
```regex
# Pattern to detect this anti-pattern in code
# Use named capture groups when useful
(?P<function_name>defp?\s+\w+).*(?P<problematic_pattern>specific_text_to_match)
```

## AST Analysis Rules
```elixir
# Pseudo-code for AST-based detection
# Look for specific AST node patterns
defmodule PatternDetector do
  def detect_pattern(ast_node) do
    # AST traversal logic
    # Return {line_number, severity, description}
  end
end
```

## Semantic Analysis Prompts
```text
Analyze this Elixir code for [specific pattern name]:
- Look for [specific behaviors]
- Flag instances where [conditions]
- Consider context of [surrounding code patterns]
- Return findings with line numbers and explanations
```

# GitHub Integration

## Comment Template
```markdown
🚨 **[Severity Level]** Anti-pattern detected: Pattern Name

**Issue**: Brief description of the problem found

**Location**: `filename:line_number`

**Problem**:
```elixir
# Show the problematic code
```

**Suggested Fix**:
```elixir
# Show the corrected version
```

**Why**: Brief explanation of why this change improves the code

**Time Estimate**: ~X minutes to fix

**References**: 
- [Pattern Documentation](link to this file)
- [Related Style Guide](link if applicable)
```

## Targeting Rules
- **File patterns**: `*.ex`, `*.exs`
- **Line targeting**: Exact line number from detection
- **Context lines**: Include 2-3 lines before/after for context
- **Multiple instances**: Group similar issues in same file

# Related Patterns

- [Other Pattern Name](../category/other-pattern.md) - Similar or related issue
- [Dependency Pattern](../integrations/library/related.md) - Integration-specific variant

# References

- [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- [Phoenix Framework Docs](https://hexdocs.pm/phoenix/overview.html)
- [Relevant Library Documentation](https://hexdocs.pm/library_name)
- [Internal Style Guide Reference](../../../q-elixir-style-guide.md)

# Metrics

- **Detection Frequency**: Track how often this pattern is found
- **Fix Success Rate**: Track resolution rate after flagging
- **False Positive Rate**: Monitor accuracy of detection rules
- **Time to Resolution**: Average time to fix after detection

---

*Last updated: YYYY-MM-DD*  
*Pattern version: 1.0*