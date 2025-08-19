#!/bin/bash

# Elixir Code Review Framework - Installation Script
# Sets up the framework for automated code reviews

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo -e "${GREEN}"
echo "==============================================="
echo "  Elixir Code Review Framework Setup"
echo "==============================================="
echo -e "${NC}"

# Check prerequisites
log_info "Checking prerequisites..."

# Check for superclaude/claude
if command -v superclaude &> /dev/null; then
    CLAUDE_CMD="superclaude"
    log_success "Found superclaude CLI"
elif command -v claude &> /dev/null; then
    CLAUDE_CMD="claude"
    log_success "Found claude CLI"
else
    log_error "Claude CLI not found. Please install Claude Code first:"
    echo "  Visit: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# Check Claude version and MCP support
log_info "Checking Claude MCP server support..."
$CLAUDE_CMD <<EOF
Please verify that the following MCP servers are available:
1. GitHub MCP (mcp__github__*)
2. Sequential-thinking MCP (mcp__sequential-thinking__*)

If any are missing, please install them according to Claude Code documentation.
EOF

# Setup configuration files
log_info "Setting up configuration files..."

cd "$ROOT_DIR"

# Create example config if repositories.yaml doesn't exist
if [ ! -f "config/repositories.yaml" ]; then
    log_warning "repositories.yaml not found, creating example"
    cp "config/repositories.yaml" "config/repositories.yaml.example"
    log_info "Please edit config/repositories.yaml with your repository details"
else
    log_success "repositories.yaml already configured"
fi

# Make scripts executable
log_info "Making scripts executable..."
chmod +x scripts/*.sh
log_success "Scripts are now executable"

# Create local bin symlink if desired
read -p "Create symlink to review-pr.sh in /usr/local/bin? (y/N): " create_symlink
if [[ $create_symlink =~ ^[Yy]$ ]]; then
    if [ -w /usr/local/bin ]; then
        ln -sf "$ROOT_DIR/scripts/review-pr.sh" /usr/local/bin/review-pr
        log_success "Created symlink: /usr/local/bin/review-pr"
    else
        log_warning "Cannot write to /usr/local/bin. You may need sudo:"
        echo "  sudo ln -sf $ROOT_DIR/scripts/review-pr.sh /usr/local/bin/review-pr"
    fi
fi

# Test the installation
log_info "Testing installation..."

./scripts/review-pr.sh --help > /dev/null
log_success "review-pr.sh is working correctly"

# Show next steps
echo ""
echo -e "${GREEN}==============================================="
echo "  Installation Complete!"
echo "===============================================${NC}"
echo ""
echo "Next steps:"
echo "1. Edit config/repositories.yaml with your repository details"
echo "2. Test with: ./scripts/review-pr.sh --help"
echo "3. Run your first review: ./scripts/review-pr.sh --interactive"
echo ""
echo "Documentation:"
echo "- Setup Guide: docs/setup.md"
echo "- Usage Guide: docs/usage.md"
echo "- Adding Patterns: docs/adding-patterns.md"
echo ""
echo "Happy code reviewing! 🚀"
