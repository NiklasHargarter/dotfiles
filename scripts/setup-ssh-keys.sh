#!/usr/bin/env bash
# Generate and deploy ed25519 SSH keys based on declarations in your SSH
# config. Each managed Host block must be preceded by a comment line of the
# form `# deploy: server` or `# deploy: manual`, and have an IdentityFile.
# The SSH config is the single source of truth — host, user, key path, and
# deploy mode all come from there.
#
# Usage:
#   ./setup-ssh-keys.sh              — process every annotated Host
#   ./setup-ssh-keys.sh <host>       — process only the given Host alias
#   SSH_CONFIG=path ./setup-ssh-keys.sh   — point at a different config file
#
# Modes:
#   server  — generate key + ssh-copy-id to the Host alias
#   manual  — generate key + copy public key to clipboard (you paste it into
#             the service's web UI / config yourself)
set -euo pipefail

CONFIG="${SSH_CONFIG:-$HOME/.config/ssh/config}"

if [[ ! -f "$CONFIG" ]]; then
    echo "SSH config not found: $CONFIG" >&2
    exit 1
fi

generate_key() {
    local label="$1" keyfile="$2"

    if [[ -f "$keyfile" ]]; then
        echo "  key exists: $keyfile"
        return
    fi

    mkdir -p "$(dirname "$keyfile")"
    echo "  generating $keyfile"
    echo "  (you will be prompted for a passphrase)"
    ssh-keygen -t ed25519 -C "niklas@$(hostname)-to-$label" -f "$keyfile"
}

deploy_server() {
    local host="$1" keyfile="$2"
    generate_key "$host" "$keyfile"
    echo "  ssh-copy-id $host"
    ssh-copy-id -i "${keyfile}.pub" "$host"
}

deploy_manual() {
    local host="$1" keyfile="$2"
    generate_key "$host" "$keyfile"
    local pubkey="${keyfile}.pub"

    if command -v pbcopy >/dev/null; then
        pbcopy < "$pubkey"
        echo "  pubkey for $host copied to clipboard (macOS) — paste it into the service's SSH-keys page"
    elif command -v xclip >/dev/null; then
        xclip -sel clip < "$pubkey"
        echo "  pubkey for $host copied to clipboard (Linux) — paste it into the service's SSH-keys page"
    else
        echo "  --- pubkey for $host ---"
        cat "$pubkey"
    fi
}

# Emit one TAB-separated line per annotated Host: mode<TAB>host<TAB>identityfile
# Hosts without a `# deploy:` marker on the immediately preceding lines, or
# without an IdentityFile, are silently skipped.
parse_config() {
    awk '
        function emit() {
            if (host != "" && mode != "" && idfile != "")
                print mode "\t" host "\t" idfile
        }
        /^[[:space:]]*#[[:space:]]*deploy:/ {
            pending_mode = $0
            sub(/^[[:space:]]*#[[:space:]]*deploy:[[:space:]]*/, "", pending_mode)
            sub(/[[:space:]]+$/, "", pending_mode)
            next
        }
        /^[[:space:]]*Host[[:space:]]+/ {
            emit()
            host = $2
            idfile = ""
            mode = pending_mode
            pending_mode = ""
        }
        /^[[:space:]]*IdentityFile[[:space:]]+/ {
            idfile = $2
        }
        END { emit() }
    ' "$1"
}

filter="${1:-}"
found=0

while IFS=$'\t' read -r mode host idfile; do
    [[ -n "$filter" && "$filter" != "$host" ]] && continue
    found=1

    keyfile="${idfile/#\~/$HOME}"

    echo "==> $host  (mode=$mode  key=$keyfile)"
    case "$mode" in
        server) deploy_server "$host" "$keyfile" ;;
        manual) deploy_manual "$host" "$keyfile" ;;
        *)      echo "  unknown deploy mode '$mode' (expected server|manual)" >&2 ;;
    esac
done < <(parse_config "$CONFIG")

if [[ -n "$filter" && "$found" == 0 ]]; then
    echo "No annotated Host '$filter' found in $CONFIG" >&2
    echo "(make sure the block has a '# deploy: server|manual' marker and an IdentityFile)" >&2
    exit 1
fi
