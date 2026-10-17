#!/usr/bin/env bash
set -e

# Run branding script
if [[ -x /usr/local/bin/apply-twilight-branding ]]; then
    /usr/local/bin/apply-twilight-branding
fi
