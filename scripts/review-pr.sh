#!/bin/bash

# Elixir Code Review Framework - Main Review Script
# Usage: ./scripts/review-pr.sh [--pr-name "PR Name"] [--interactive] [--config path/to/config]

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration
CONFIG_DIR="$ROOT_DIR/config"
PATTERNS_DIR="$ROOT_DIR/patterns"
REPO_CONFIG="$CONFIG_DIR/repositories.yaml"
SEVERITY_CONFIG="$CONFIG_DIR/severity-levels.yaml"
TEMPLATES_CONFIG="$CONFIG_DIR/github-templates.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PR_NAME=""
INTERACTIVE=false
CONFIG_PATH="$CONFIG_DIR"
VERBOSE=false
DRY_RUN=false

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_usage() {
    echo "Elixir Code Review Framework"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --pr-name NAME        Specific PR name to review"
    echo "  --interactive         Select PR from list interactively"
    echo "  --config PATH         Path to configuration directory (default: ./config)"
    echo "  --dry-run            Show what would be done without making changes"
    echo "  --verbose            Show detailed output"
    echo "  --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --pr-name \"Fix authentication bug\""
    echo "  $0 --interactive"
    echo "  $0 --dry-run --verbose"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --pr-name)
            PR_NAME="$2"
            shift 2
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        --config)
            CONFIG_PATH="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    # Check if superclaude is available
    if ! command -v superclaude &> /dev/null; then
        log_error "superclaude not found. Please install Claude Code CLI."
        exit 1
    fi
    
    # Check if required config files exist
    if [ ! -f "$REPO_CONFIG" ]; then
        log_error "Repository config not found: $REPO_CONFIG"
        log_info "Please copy config/repositories.yaml.example to config/repositories.yaml and configure it."
        exit 1
    fi
    
    log_success "All dependencies satisfied"
}

# Get list of open PRs for interactive selection
get_open_prs() {
    log_info "Fetching open pull requests..."
    
    # Use superclaude with GitHub MCP to get PR list
    superclaude <<EOF
I need to get the list of open pull requests for the repository configured in $REPO_CONFIG. 
Please use the GitHub MCP server to list open PRs and format the output as a numbered list with PR names and numbers.
EOF
}

# Interactive PR selection
select_pr_interactive() {
    log_info "Interactive PR selection mode"
    
    # Get PR list
    get_open_prs
    
    echo ""
    read -p "Enter the PR name or number to review: " pr_selection
    PR_NAME="$pr_selection"
    
    if [ -z "$PR_NAME" ]; then
        log_error "No PR selected"
        exit 1
    fi
}

# Main review function
run_code_review() {
    local pr_name="$1"
    
    log_info "Starting code review for PR: $pr_name"
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi
    
    # Create temporary directory for analysis
    local temp_dir=$(mktemp -d)
    local analysis_file="$temp_dir/analysis_results.json"
    
    # Run the analysis using superclaude with sequential thinking
    log_info "Analyzing PR with sequential thinking and pattern detection..."
    
    superclaude <<EOF
I need you to perform a comprehensive code review analysis using the elixir-code-review framework.

**Task**: Analyze PR "$pr_name" for anti-patterns

**Steps**:
1. Use GitHub MCP to get the PR diff and changed files
2. Use sequential-thinking MCP for deep analysis against patterns in $PATTERNS_DIR
3. Check each changed .ex/.exs file against all applicable patterns:
   - Architectural patterns (auth bypass, PubSub leaks, etc.)
   - File-level patterns (boolean logic, complexity, etc.)
   - Integration patterns (Ecto, Phoenix, Bodyguard, etc.)
4. Generate findings with:
   - Pattern name and severity
   - Exact file and line numbers
   - Code examples (bad and good)
   - Time estimates
   - Breaking change risk

**Output**: Save results to $analysis_file in JSON format with structure:
{
  "pr_name": "$pr_name",
  "total_issues": number,
  "issues": [
    {
      "pattern": "pattern-name",
      "severity": "critical|high|medium|low",
      "category": "architectural|file-level|one-liners|integrations",
      "file": "path/to/file.ex",
      "line": number,
      "description": "Issue description",
      "bad_example": "code",
      "good_example": "corrected code",
      "time_minutes": number,
      "breaking_change_risk": "low|medium|high"
    }
  ],
  "summary": {
    "critical": number,
    "high": number,
    "medium": number,
    "low": number,
    "total_time_hours": number,
    "estimated_cost_savings": number
  }
}

**Use**: 
- Sequential-thinking for complex architectural analysis
- GitHub MCP for PR operations and commenting
- Pattern files from $PATTERNS_DIR for detection rules
- Template files from $TEMPLATES_CONFIG for comment formatting

If dry-run mode: $DRY_RUN, don't create actual GitHub comments, just show what would be posted.
EOF
    
    # Process the results
    if [ -f "$analysis_file" ]; then
        log_success "Analysis complete! Results saved to $analysis_file"
        
        # Show summary
        log_info "Review Summary:"
        # Parse JSON and show summary (would need jq or similar)
        
    else
        log_error "Analysis failed - no results file generated"
        exit 1
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Main execution
main() {
    log_info "Elixir Code Review Framework v1.0"
    
    # Check dependencies
    check_dependencies
    
    # Determine PR to review
    if [ "$INTERACTIVE" = true ]; then
        select_pr_interactive
    elif [ -z "$PR_NAME" ]; then
        log_error "No PR specified. Use --pr-name or --interactive"
        show_usage
        exit 1
    fi
    
    # Run the review
    run_code_review "$PR_NAME"
    
    log_success "Code review completed for PR: $PR_NAME"
}

# Execute main function
main "$@"