export PATH="$PATH:$HOME/.local/bin:$HOME/.npm-global/bin"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
HYPHEN_INSENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 14

plugins=(
	git
	fzf
	eza
	zsh-autosuggestions
	zsh-completions
	fzf-tab
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k config if present.
[[ -r "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"

# Editor
export EDITOR='nvim'

# Source modular config fragments (each file guards its own dependencies)
for conf in "$ZDOTDIR/conf.d/"*.zsh(N); do source "$conf"; done
unset conf
