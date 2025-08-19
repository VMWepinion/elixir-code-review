---
title: "[Library Name] - Specific Pattern Name"
severity: critical|high|medium|low
category: integrations
integration: ecto|phoenix|postgrex|bodyguard|mock|genserver|other
detection_method: regex|ast|semantic|hybrid
estimated_fix_time_minutes: number
breaking_change_risk: low|medium|high
tags: [library_name, specific_feature, pattern_type]
version: "1.0"
created_date: "YYYY-MM-DD"
last_updated: "YYYY-MM-DD"
---

# Integration Pattern: [Library Name]

## Anti-Pattern Description

Specific description of how this library is commonly misused or integrated incorrectly.

## Library Context

- **Library**: [Name and version]
- **Documentation**: [Link to official docs]
- **Common Use Cases**: Where this pattern typically appears
- **Integration Points**: How it connects with Phoenix/Elixir ecosystem

# Examples of Bad Integration

```elixir
# ❌ BAD: Incorrect usage of [Library Feature]
defmodule BadIntegration do
  # Show library-specific anti-patterns
  # Focus on integration issues, not general coding problems
end
```

# Correct Integration Patterns

```elixir
# ✅ GOOD: Proper integration with [Library]
defmodule GoodIntegration do
  # Show proper setup, configuration, and usage
  # Include error handling specific to this library
end
```

# Library-Specific Detection

## Import/Alias Patterns
```regex
# Detect specific import or alias patterns that indicate misuse
```

## Function Call Patterns
```regex
# Detect problematic function calls or configurations
```

## Configuration Issues
```elixir
# Config validation patterns
# Look for common misconfigurations
```

# Integration Best Practices

1. **Setup**: Proper installation and configuration
2. **Usage**: Correct API usage patterns
3. **Error Handling**: Library-specific error patterns
4. **Performance**: Integration performance considerations
5. **Testing**: How to properly test this integration

# Common Gotchas

- **Version Compatibility**: Known version issues
- **Configuration Traps**: Easy mistakes in config
- **Performance Pitfalls**: Common performance issues
- **Security Considerations**: Integration security concerns

# References

- [Official Documentation](library-docs-url)
- [Integration Examples](examples-url)
- [Community Best Practices](community-url)
- [Related Wepinion Patterns](../architectural/related-pattern.md)

---

*Library Version Tested: X.Y.Z*  
*Pattern Version: 1.0*