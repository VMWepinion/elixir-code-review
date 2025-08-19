---
title: "Manual Authorization Bypass"
severity: critical
category: architectural
detection_method: semantic
estimated_fix_time_minutes: 45
breaking_change_risk: medium
tags: [bodyguard, authorization, security, policy]
version: "1.0"
created_date: "2025-08-19"
last_updated: "2025-08-19"
---

# Bad Behavior Description

Manual authorization logic that bypasses established Bodyguard policy patterns. This creates security vulnerabilities, inconsistent authorization logic, and maintenance overhead. Developers often create custom authorization checks instead of using the standardized Bodyguard.permit/4 pattern.

## Context

- **When it appears**: Permission checking functions, controller actions, API endpoints
- **Why developers do this**: Seems faster than setting up proper policies, unfamiliarity with Bodyguard patterns
- **Risk level**: **CRITICAL** - Can lead to authorization bypass vulnerabilities

# Examples of Bad Behavior

```elixir
# ❌ BAD: Manual role checking with cond statements
defp check_removal_permissions(scope, remover_handle, circle_name) do
  user_roles = User.get_roles(scope.current_user)
  admin_role_atoms = [:admin, :super_admin, :system_admin]
  
  cond do
    Enum.any?(user_roles, &(&1 in admin_role_atoms)) -> :ok
    circle_manager?(scope, circle_name) -> :ok
    true -> {:error, :insufficient_permissions}
  end
end
```

```elixir
# ❌ BAD: Direct membership checking without policy
def can_remove_member?(user, circle_name, member_handle) do
  case CircleMembership.get_membership(user.handle, circle_name) do
    %CircleMembership{role: role} when role in ["creator", "admin", "moderator"] -> true
    nil -> false
    _ -> false
  end
end
```

```elixir
# ❌ BAD: Inline permission checks in controllers
def remove_member(conn, %{"circle_name" => circle_name, "member_handle" => member_handle}) do
  current_user = conn.assigns.current_user
  
  if current_user.role == "admin" or CircleMembership.is_circle_admin?(current_user.handle, circle_name) do
    # Remove member logic
    render(conn, "success.json")
  else
    conn
    |> put_status(403)
    |> render("error.json", message: "Insufficient permissions")
  end
end
```

# Solutions

```elixir
# ✅ GOOD: Use Bodyguard policy with early authorization check
def remove_member(conn, %{"circle_name" => circle_name, "member_handle" => member_handle}) do
  current_user = conn.assigns.current_user
  
  case Bodyguard.permit(CirclePolicy, :remove_member, current_user, {circle_name, member_handle}) do
    :ok -> 
      # Authorization passed, proceed with business logic
      case Circles.remove_member(circle_name, member_handle) do
        {:ok, result} -> render(conn, "success.json", data: result)
        {:error, reason} -> render(conn, "error.json", message: reason)
      end
    
    {:error, :unauthorized} -> 
      conn
      |> put_status(403) 
      |> render("error.json", message: "Insufficient permissions")
  end
end
```

```elixir
# ✅ GOOD: Proper policy implementation
defmodule CirclePolicy do
  @behaviour Bodyguard.Policy

  def authorize(:remove_member, user, {circle_name, member_handle}) do
    cond do
      User.admin?(user) -> :ok
      CircleMembership.circle_manager?(user.handle, circle_name) -> :ok
      true -> {:error, :unauthorized}
    end
  end
  
  def authorize(action, user, resource) do
    {:error, :unauthorized}
  end
end
```

```elixir
# ✅ GOOD: Service layer with authorization
defmodule Circles do
  def remove_member(circle_name, member_handle, requesting_user) do
    with :ok <- Bodyguard.permit(CirclePolicy, :remove_member, requesting_user, {circle_name, member_handle}),
         {:ok, member} <- get_member(circle_name, member_handle),
         {:ok, result} <- do_remove_member(member) do
      {:ok, result}
    else
      {:error, reason} -> {:error, reason}
    end
  end
  
  defp do_remove_member(member) do
    # Actual removal logic here
  end
end
```

# Detection Rules

## Regex Patterns
```regex
# Detect manual cond-based authorization
(?P<function>defp?\s+\w*(?:check|can|auth|permit|allow)\w*).*?cond\s+do.*?(?P<roles>admin|super_admin|moderator).*?-> :ok

# Detect inline role checking
(?P<inline_check>if\s+.*?\.role\s*==\s*["'](?:admin|moderator|creator)["'])

# Detect manual membership role checking
(?P<membership_check>role\s+in\s+\[["'](?:creator|admin|moderator)["']
```

## AST Analysis Rules
```elixir
defmodule AuthBypassDetector do
  def detect_manual_auth(ast_node) do
    # Look for cond statements with role checking
    # Flag functions with authorization-related names that don't use Bodyguard
    # Return {line_number, :critical, "Manual authorization bypass detected"}
  end
end
```

## Semantic Analysis Prompts
```text
Analyze this Elixir code for manual authorization bypassing Bodyguard patterns:
- Look for functions with names like check_*, can_*, authorize_*, permit_* that don't use Bodyguard.permit/4
- Flag cond statements or if/else chains checking user roles directly  
- Identify inline authorization logic in controllers instead of policy delegation
- Flag direct membership role checking without going through policies
- Return findings with line numbers and specific anti-pattern descriptions
```

# GitHub Integration

## Comment Template
```markdown
🚨 **CRITICAL** Anti-pattern detected: Manual Authorization Bypass

**Issue**: Custom authorization logic bypassing established Bodyguard patterns

**Location**: `filename:line_number`

**Problem**:
```elixir
# Show the problematic manual authorization code
```

**Suggested Fix**:
```elixir
# Use Bodyguard policy instead
case Bodyguard.permit(PolicyModule, :action, user, resource) do
  :ok -> # proceed with authorized action
  {:error, reason} -> {:error, reason}
end
```

**Why**: Manual authorization creates security risks, inconsistent behavior, and is harder to test and maintain. Bodyguard provides standardized, testable authorization patterns.

**Time Estimate**: ~45 minutes to refactor to proper policy

**References**: 
- [Manual Authorization Bypass Pattern](../../patterns/architectural/manual-authorization-bypass.md)
- [Bodyguard Documentation](https://hexdocs.pm/bodyguard)
- [Elixir Authorization Guide](../../../q-elixir-style-guide.md#authorization)
```

## Targeting Rules
- **File patterns**: `*_controller.ex`, `*_policy.ex`, `lib/**/*.ex`
- **Function patterns**: Functions with authorization-related names
- **Context lines**: Include full function definition for context
- **Priority**: CRITICAL - flag immediately for review

# Related Patterns

- [Policy Missing Implementation](../file-level/policy-missing.md) - Missing Bodyguard policies
- [Controller Authorization](../integrations/phoenix/controller-auth.md) - Phoenix-specific auth patterns

# References

- [Bodyguard Documentation](https://hexdocs.pm/bodyguard)
- [Elixir Authorization Patterns](https://github.com/christopheradams/elixir_style_guide#authorization)
- [Phoenix Security Guide](https://hexdocs.pm/phoenix/security.html)
- [Wepinion Style Guide](../../../q-elixir-style-guide.md)

# Metrics

- **Detection Frequency**: High priority - check every PR
- **Fix Success Rate**: Target 100% resolution
- **False Positive Rate**: Monitor for legitimate custom auth cases
- **Security Impact**: Critical - immediate attention required

---

*Last updated: 2025-08-19*  
*Pattern version: 1.0*