command -v zoxide >/dev/null || return

# zoxide as `cd` — frecency-aware jumping, transparent fallback to real cd.
#   cd foo        jump to best-matched dir you've visited
#   cd bar baz    match by fragments
#   cdi           interactive fzf pick
# Bound to `cd`, not `z`, so it works without having to remember a new verb.
eval "$(zoxide init zsh --cmd cd)"
