command -v zellij >/dev/null || return

# Fast attach-or-create by name — unlimited sessions, no per-name alias needed:
#   zj          → session "main"
#   zj scrape   → session "scrape"
# `zellij attach` from inside a session nests one session in another instead of
# switching — switch-session is the in-session equivalent that actually swaps.
zj() {
  local s="${1:-main}"
  if [[ -n "$ZELLIJ" ]]; then zellij action switch-session "$s"
  else zellij attach --create "$s"; fi
}

# The named sessions are reached by key, not by alias: Alt+1 main, Alt+2 work,
# Alt+3 project (SwitchSession binds in ~/.config/zellij/config.kdl). Ctrl+o w
# opens the session-manager for anything outside those three. `zj <name>` above
# is the only shell entry still worth having — for creating an ad-hoc session.

# Auto-resume on the 24/7 workstations: an interactive SSH login drops straight
# into the persistent "main" session. Local shells and non-interactive/scp
# connections are untouched. Escape hatch:  NO_ZELLIJ=1 ssh host
if [[ -n "$SSH_TTY" && -z "$ZELLIJ" && -z "$NO_ZELLIJ" && $- == *i* ]]; then
  zellij attach --create main
fi
