#!/bin/bash

# Update and install necessary packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y git zsh bat fzf exa python3-pip curl nala zoxide xdg-utils

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use

# Install The Fuck
pip3 install thefuck

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Starship prompt
curl -sS https://starship.rs/install.sh | sh

# Install Zed editor
sudo apt install -y snapd
sudo snap install zed --classic

# Create .zshrc file
cat <<EOL > ~/.zshrc
# Path to your oh-my-zsh installation
ZSH="\$HOME/.oh-my-zsh"

# Ensure .local/bin is in PATH
export PATH="\$HOME/.local/bin:\$PATH"

# Zsh Theme Configuration
ZSH_THEME=""

# Plugins Configuration
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  you-should-use
)

# Load oh-my-zsh
source \$ZSH/oh-my-zsh.sh

# Initialize Homebrew
eval "\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Add Zed to PATH
export PATH="\$PATH:/opt/zed"

# Initialize zoxide
eval "\$(zoxide init zsh)"

# The Fuck Plugin Configuration
if command -v thefuck > /dev/null; then
    eval \$(thefuck --alias)
else
    echo "thefuck is not installed or not in your PATH."
fi

fuck-command-line() {
    local FUCK="\$(THEFUCK_REQUIRE_CONFIRMATION=0 thefuck \$(fc -ln -1 | tail -n 1) 2> /dev/null)"
    [[ -z \$FUCK ]] && echo -n -e "\a" && return
    BUFFER=\$FUCK
    zle end-of-line
}
zle -N fuck-command-line

# Define shortcut keys: [Esc] [Esc]
bindkey -M emacs '\e\e' fuck-command-line
bindkey -M vicmd '\e\e' fuck-command-line
bindkey -M viins '\e\e' fuck-command-line

# Function to determine the correct bat command
bat_command() {
    if command -v bat &> /dev/null; then
        echo "bat"
    elif command -v batcat &> /dev/null; then
        echo "batcat"
    else
        echo "cat"
    fi
}

# Set FZF to use bat (or batcat) for previews
export FZF_DEFAULT_OPTS="--preview '\$(bat_command) --style=numbers --color=always {}'"

# Functions
fzf_open() {
    local file
    file=\$(fzf --prompt='Select a file: ')
    [ -n "\$file" ] && xdg-open "\$file"
}

# Alias for fzf_open
alias fz='fzf_open'

# Remove existing aliases if any
unalias cat 2>/dev/null
unalias batcat 2>/dev/null

# Function for bat and cat
cat() {
    if command -v batcat &> /dev/null; then
        batcat --paging=never "\$@"
    elif command -v bat &> /dev/null; then
        bat --paging=never "\$@"
    else
        /bin/cat "\$@"
    fi
}

# Aliases for exa
alias ls='exa'
alias ll='exa -l'
alias la='exa -a'
alias lla='exa -la'
alias lt='exa --tree'
alias llh='exa -lh'
alias lld='exa -l --dirs-only'

# Nala as default package manager
alias apt='sudo nala'

# Starship Prompt
eval "\$(starship init zsh)"
EOL

# Change default shell to zsh
chsh -s $(which zsh)

echo "Setup completed! Please restart your terminal or run 'zsh' to start using the new configuration."