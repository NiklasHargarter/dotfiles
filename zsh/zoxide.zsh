command -v zoxide >/dev/null || return

# zoxide as `cd` — frecency-aware jumping, transparent fallback to real cd.
#   cd foo        jump to best-matched dir you've visited
#   cd bar baz    match by fragments
#   cdi           interactive fzf pick
# `z` stays zellij's (see zellij.zsh); zoxide takes over `cd` instead of `z`.
eval "$(zoxide init zsh --cmd cd)"
