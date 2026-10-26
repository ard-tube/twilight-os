#!/usr/bin/env bash
# ==============================================================================
# Twilight OS Live Environment Customizer
# ==============================================================================
set -e

# Run branding script
if [[ -x /usr/local/bin/apply-twilight-branding ]]; then
    /usr/local/bin/apply-twilight-branding
fi

# Clean up caches and docs to reduce live SquashFS size
rm -rf /var/cache/pacman/pkg/* 2>/dev/null || true
rm -rf /usr/share/doc/* 2>/dev/null || true
rm -rf /usr/share/man/* 2>/dev/null || true
