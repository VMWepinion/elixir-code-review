---
title: "PubSub Data Leak Vulnerabilities"
severity: critical
category: architectural
detection_method: hybrid
estimated_fix_time_minutes: 30
breaking_change_risk: low
tags: [phoenix, pubsub, security, privacy, data-leak]
version: "1.0"
created_date: "2025-08-19"
last_updated: "2025-08-19"
---

# Bad Behavior Description

Using generic PubSub topics that broadcast sensitive data to unintended subscribers. This creates data privacy vulnerabilities where users can receive information they shouldn't have access to. The anti-pattern involves broadcasting to broad topics like "circles", "users", or "general" instead of user-specific or permission-scoped topics.

## Context

- **When it appears**: Phoenix PubSub broadcasts, LiveView updates, real-time notifications
- **Why developers do this**: Simpler to implement, easier to debug initially, misunderstanding of PubSub security model
- **Risk level**: **CRITICAL** - Direct data privacy violation, potential GDPR/compliance issues

# Examples of Bad Behavior

```elixir
# ❌ BAD: Generic topic broadcasts sensitive membership data
Phoenix.PubSub.broadcast(
  WepinionCore.PubSub, 
  "circles", 
  {:membership_change, member_handle, circle_name, action, member_details}
)
# Any subscriber to "circles" receives ALL membership changes
```

```elixir
# ❌ BAD: User data broadcast to generic topic
Phoenix.PubSub.broadcast(
  MyApp.PubSub,
  "user_updates",
  {:profile_change, user_id, personal_data}
)
# All subscribers get everyone's profile changes
```

```elixir
# ❌ BAD: Broadcasting private messages to broad topic
Phoenix.PubSub.broadcast(
  ChatApp.PubSub,
  "messages",
  {:new_message, from_user, to_user, private_message_content}
)
# Everyone subscribed to "messages" sees private conversations
```

```elixir
# ❌ BAD: Generic notification broadcasting
def notify_members(circle_name, notification_data) do
  Phoenix.PubSub.broadcast(
    WepinionCore.PubSub,
    "notifications",
    {:circle_notification, circle_name, notification_data}
  )
end
# All users get notifications for all circles
```

# Solutions

```elixir
# ✅ GOOD: User-specific topic prevents data leaks
Phoenix.PubSub.broadcast(
  WepinionCore.PubSub,
  "user:#{current_user.handle}",
  {:membership_change, circle_name, action}
)
# Only the specific user receives their membership updates
```

```elixir
# ✅ GOOD: Circle-scoped topic with proper authorization
Phoenix.PubSub.broadcast(
  WepinionCore.PubSub,
  "circle:#{circle_name}",
  {:membership_change, member_handle, action}
)
# Only users subscribed to this specific circle get updates
```

```elixir
# ✅ GOOD: Private message channel between specific users
Phoenix.PubSub.broadcast(
  ChatApp.PubSub,
  "conversation:#{conversation_id}",
  {:new_message, from_user, message_content}
)
# Only participants in this conversation receive messages
```

```elixir
# ✅ GOOD: Notify only authorized circle members
def notify_circle_members(circle_name, notification_data) do
  # Get list of authorized members
  authorized_members = CircleMembership.get_member_handles(circle_name)
  
  Enum.each(authorized_members, fn member_handle ->
    Phoenix.PubSub.broadcast(
      WepinionCore.PubSub,
      "user:#{member_handle}",
      {:circle_notification, circle_name, notification_data}
    )
  end)
end
```

```elixir
# ✅ GOOD: Subscription with authorization check
defmodule MyAppWeb.CircleLive do
  def mount(_params, %{"circle_name" => circle_name}, socket) do
    current_user = socket.assigns.current_user
    
    case Bodyguard.permit(CirclePolicy, :view, current_user, circle_name) do
      :ok ->
        Phoenix.PubSub.subscribe(WepinionCore.PubSub, "circle:#{circle_name}")
        {:ok, assign(socket, :circle_name, circle_name)}
      
      {:error, :unauthorized} ->
        {:ok, redirect(socket, to: "/unauthorized")}
    end
  end
end
```

# Detection Rules

## Regex Patterns
```regex
# Detect generic topic broadcasts
Phoenix\.PubSub\.broadcast\([^,]+,\s*["'](?P<generic_topic>circles|users|notifications|messages|general|all)["']\s*,

# Detect broad topic names without scoping
["'](?P<broad_topic>\w+)(?<!user:|circle:|conversation:|private:)["']\s*,\s*\{[^}]*(?P<sensitive_data>handle|email|private|personal|secret)
```

## AST Analysis Rules
```elixir
defmodule PubSubLeakDetector do
  def detect_data_leaks(ast_node) do
    # Look for Phoenix.PubSub.broadcast calls
    # Check topic names for generic patterns
    # Flag broadcasts with sensitive data to generic topics
    # Return {line_number, :critical, "PubSub data leak detected"}
  end
end
```

## Semantic Analysis Prompts
```text
Analyze this Elixir Phoenix code for PubSub data leak vulnerabilities:
- Look for Phoenix.PubSub.broadcast calls using generic topic names like "circles", "users", "notifications", "messages"
- Flag broadcasts that include sensitive data (user handles, personal info, private messages) to broad topics
- Identify subscription patterns that don't include authorization checks
- Check for topics that don't use user-specific or resource-specific scoping (user:id, circle:name, etc.)
- Return findings with line numbers and specific data leak risks
```

# GitHub Integration

## Comment Template
```markdown
🚨 **CRITICAL** Anti-pattern detected: PubSub Data Leak Vulnerability

**Issue**: Broadcasting sensitive data to generic topic that could leak to unauthorized subscribers

**Location**: `filename:line_number`

**Problem**:
```elixir
# Show the problematic generic broadcast
```

**Data Leak Risk**: Subscribers to generic topic `"topic_name"` will receive sensitive data intended for specific users/resources.

**Suggested Fix**:
```elixir
# Use scoped topics to prevent data leaks
Phoenix.PubSub.broadcast(PubSub, "user:#{user_id}", message)
# or
Phoenix.PubSub.broadcast(PubSub, "resource:#{resource_id}", message)
```

**Why**: Generic topics create data privacy violations. Users can receive information they're not authorized to see, violating security boundaries and potentially compliance requirements.

**Time Estimate**: ~30 minutes to scope topic properly

**References**: 
- [PubSub Data Leak Pattern](../../patterns/architectural/pubsub-data-leaks.md)
- [Phoenix PubSub Security Guide](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html)
- [Privacy-First Development](../../../q-context.md#privacy)
```

## Targeting Rules
- **File patterns**: `*_live.ex`, `*_channel.ex`, `lib/**/*.ex`
- **Function patterns**: Functions calling Phoenix.PubSub.broadcast
- **Context lines**: Include full broadcast call and surrounding context
- **Priority**: CRITICAL - immediate security review required

# Related Patterns

- [Missing Authorization Checks](../file-level/missing-authorization.md) - Related authorization issues
- [Phoenix LiveView Security](../integrations/phoenix/liveview-security.md) - LiveView-specific security patterns

# References

- [Phoenix PubSub Documentation](https://hexdocs.pm/phoenix_pubsub)
- [Phoenix Security Guide](https://hexdocs.pm/phoenix/security.html)
- [Elixir Privacy Patterns](https://elixir-lang.org/getting-started/mix-otp/genserver.html#privacy)
- [OWASP Data Exposure Prevention](https://owasp.org/www-project-top-ten/2017/A3_2017-Sensitive_Data_Exposure)

# Metrics

- **Detection Frequency**: High priority - check every PubSub usage
- **Fix Success Rate**: Target 100% resolution  
- **Security Impact**: Critical - data privacy violation
- **Compliance Risk**: High - potential GDPR/privacy regulation violations

---

*Last updated: 2025-08-19*  
*Pattern version: 1.0*