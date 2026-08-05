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

# This week's keybinding focus. `focus -e` to edit it on Monday.
focus() {
  [[ "$1" == "-e" ]] && { $EDITOR ~/dotfiles/FOCUS.md; return; }
  command -v batcat >/dev/null && batcat --style=plain ~/dotfiles/FOCUS.md || cat ~/dotfiles/FOCUS.md
}

# Debian names bat/fd differently — alias back to the normal names when present.
command -v batcat >/dev/null && alias bat='batcat'
command -v fdfind >/dev/null && alias fd='fdfind'
