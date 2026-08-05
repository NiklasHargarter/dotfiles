# Shell aliases — add yours here. Auto-sourced from conf.d by .zshrc.

# eza (modern ls)
alias ls='eza --group-directories-first'
alias ll='eza -lah --group-directories-first --git'
alias tree='eza --tree'

alias v='nvim'
alias g='git'

# Every active zsh binding, fuzzy-searchable. zsh already knows them all, so
# there is no cheat sheet to maintain. Caret notation: ^X = Ctrl+x, ^[x = Alt+x.
# (zellij: Ctrl+o then c. nvim: press <space> and wait — which-key.)
keys() { bindkey | fzf --height 60% --reverse --prompt 'zsh keys> '; }

# Reference docs. `focus` = this week's keybinding drill, `-e` to edit it on Monday.
# `tools` = what the installed CLI tools do and how to drive them.
_read_doc() {
  [[ "$2" == "-e" ]] && { $EDITOR ~/dotfiles/$1; return; }
  command -v batcat >/dev/null && batcat --style=plain ~/dotfiles/$1 || cat ~/dotfiles/$1
}
focus() { _read_doc FOCUS.md "$1"; }
tools() { _read_doc TOOLS.md "$1"; }

# Debian names bat/fd differently — alias back to the normal names when present.
command -v batcat >/dev/null && alias bat='batcat'
command -v fdfind >/dev/null && alias fd='fdfind'
