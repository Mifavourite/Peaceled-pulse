#!/bin/bash

# Secure installation script for Flutter development environment
# This script should be verified with GPG before execution

set -e

echo "🔒 Secure Flutter App - Installation Script"
echo "=========================================="

# Check for required tools
check_dependencies() {
    echo "Checking dependencies..."
    
    if ! command -v flutter &> /dev/null; then
        echo "❌ Flutter not found. Please install Flutter first."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker not found. Please install Docker first."
        exit 1
    fi
    
    if ! command -v make &> /dev/null; then
        echo "❌ Make not found. Please install Make first."
        exit 1
    fi
    
    echo "✅ All dependencies found"
}

# Setup GPG for commit signing
setup_gpg() {
    echo "Setting up GPG for commit signing..."
    
    if command -v gpg &> /dev/null; then
        if ! gpg --list-secret-keys --keyid-format LONG | grep -q sec; then
            echo "⚠️  No GPG keys found. Generating new key..."
            echo "Please follow the prompts to create a GPG key."
            gpg --full-generate-key
        fi
        
        # Configure git to sign commits
        git config --local commit.gpgsign true
        echo "✅ GPG configured for commit signing"
    else
        echo "⚠️  GPG not found. Skipping GPG setup."
    fi
}

# Install pre-commit hooks
install_hooks() {
    echo "Installing pre-commit hooks..."
    
    if [ -d ".git" ]; then
        cp .githooks/pre-commit .git/hooks/pre-commit
        chmod +x .git/hooks/pre-commit
        echo "✅ Pre-commit hooks installed"
    else
        echo "⚠️  Not a git repository. Skipping hook installation."
    fi
}

# Setup Docker services
setup_docker() {
    echo "Setting up Docker services..."
    docker-compose pull
    echo "✅ Docker images pulled"
}

# Install Flutter dependencies
install_flutter_deps() {
    echo "Installing Flutter dependencies..."
    flutter pub get
    echo "✅ Flutter dependencies installed"
}

# Main installation
main() {
    check_dependencies
    setup_gpg
    install_hooks
    setup_docker
    install_flutter_deps
    
    echo ""
    echo "✅ Installation complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Run 'make setup' to initialize Vault"
    echo "  2. Run 'make start' to start security services"
    echo "  3. Run 'make security-scan' to perform initial security scan"
}

main
