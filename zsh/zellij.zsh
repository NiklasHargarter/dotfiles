command -v zellij >/dev/null || return

# Fast attach-or-create by name — unlimited sessions, no per-name alias needed:
#   zj          → session "main"
#   zj scrape   → session "scrape"
zj() { zellij attach --create "${1:-main}"; }

# Pick a running session with fzf (or type a new name):
zjp() {
  local s
  s=$(zellij list-sessions -s 2>/dev/null | fzf --height 40% --reverse \
        --print-query --prompt 'zellij> ' | tail -1)
  [[ -n "$s" ]] && zellij attach --create "$s"
}

alias z='zellij'
alias zl='zellij list-sessions'
alias zwork='zj work'      # muscle memory, now just a named zj
alias zproj='zj project'

# Auto-resume on the 24/7 workstations: an interactive SSH login drops straight
# into the persistent "main" session. Local shells and non-interactive/scp
# connections are untouched. Escape hatch:  NO_ZELLIJ=1 ssh host
if [[ -n "$SSH_TTY" && -z "$ZELLIJ" && -z "$NO_ZELLIJ" && $- == *i* ]]; then
  zellij attach --create main
fi
