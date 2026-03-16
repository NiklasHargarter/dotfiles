# ZSH

## download MesloLGS NF
[powerlevel10k github fonts](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#fonts)
## set zsh as default shell
    chsh -s $(which zsh) && sudo chsh -s $(which zsh) root
## stow
    stow zsh
## check for custom zsh config location
    echo $ZDOTDIR
## install ohmyzsh 
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    
## Powerlevel 10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.
    oh-my-zsh/custom}/themes/powerlevel10k"
## Plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
    git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
