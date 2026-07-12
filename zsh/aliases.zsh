# Shell aliases — add yours here. Auto-sourced from conf.d by .zshrc.

# dotfiles: edit / sync from anywhere
alias dot='cd ~/dotfiles'
alias dots='git -C ~/dotfiles status'
alias dotpull='git -C ~/dotfiles pull'

# eza (modern ls)
alias ls='eza --group-directories-first'
alias ll='eza -lah --group-directories-first --git'
alias tree='eza --tree'

alias v='nvim'
alias g='git'
