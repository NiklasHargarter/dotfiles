#!/usr/bin/env bash
# Generate an ed25519 SSH key for a service and deploy it.
#
# Usage:
#   ./setup-ssh-keys.sh server <host>   — generate key + ssh-copy-id
#   ./setup-ssh-keys.sh ui <service>    — generate key + copy to clipboard / print
set -euo pipefail

generate_key() {
    local service="$1"
    local keyfile="$HOME/.ssh/id_ed25519_${service}"

    if [[ -f "$keyfile" ]]; then
        echo "Key already exists: $keyfile"
        return
    fi

    echo "--- Generating key for $service ---"
    echo "You will now be prompted to enter a passphrase:"
    ssh-keygen -t ed25519 -C "niklas@$(hostname)-to-$service" -f "$keyfile"
}

deploy_server() {
    local service="$1"
    generate_key "$service"
    ssh-copy-id -i "$HOME/.ssh/id_ed25519_${service}.pub" "$service"
}

deploy_ui() {
    local service="$1"
    generate_key "$service"

    local pubkey="$HOME/.ssh/id_ed25519_${service}.pub"

    if command -v pbcopy >/dev/null; then
        pbcopy < "$pubkey"
        echo "Key for $service copied to clipboard (macOS)."
    elif command -v xclip >/dev/null; then
        xclip -sel clip < "$pubkey"
        echo "Key for $service copied to clipboard (Linux)."
    else
        echo "--- Public Key for $service ---"
        cat "$pubkey"
    fi
}

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <server|ui> <service_name>"
    exit 1
fi

case "$1" in
    server) deploy_server "$2" ;;
    ui)     deploy_ui "$2" ;;
    *)      echo "Unknown mode: $1 (use 'server' or 'ui')"; exit 1 ;;
esac
