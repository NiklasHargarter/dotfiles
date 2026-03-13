# system packages
    sudo apt update && sudo apt install -y stow zsh ripgrep eza fzf

# ZSH
download MesloLGS NF

    chsh -s $(which zsh) && sudo chsh -s $(which zsh) root
    
    stow zsh
    
    .setup_zsh.sh

# Neovim
    curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh | bash
