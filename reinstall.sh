#!/bin/bash

# Exit on error
set -e

# Function to run apt commands with automatic yes
apt_install() {
    DEBIAN_FRONTEND=noninteractive sudo apt-get -y install "$@"
}

# Update and install necessary packages
sudo apt-get update && sudo apt-get upgrade -y
apt_install git zsh curl wget unzip python3-pip xdg-utils zoxide

# Install nala
apt_install nala

# Install Zsh if not already installed
if ! command -v zsh &> /dev/null; then
    apt_install zsh
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || true
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use 2>/dev/null || true

# Install Homebrew
if ! command -v brew &> /dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Install packages with Homebrew
brew install bat fzf thefuck

# Install exa
wget -q http://de.archive.ubuntu.com/ubuntu/pool/universe/r/rust-exa/exa_0.10.1-2_amd64.deb
sudo dpkg -i exa_0.10.1-2_amd64.deb
rm exa_0.10.1-2_amd64.deb

# Install Starship prompt
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Download and place starship.toml
mkdir -p ~/.config
wget -q https://raw.githubusercontent.com/LostBoxArt/dotfiles/main/.config/starship.toml -O ~/.config/starship.toml

# Install Zed editor
curl -f https://zed.dev/install.sh | sh

# Install FiraCode Nerd Font
mkdir -p ~/.local/share/fonts
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip -q FiraCode.zip -d ~/.local/share/fonts
fc-cache -f
rm FiraCode.zip

# Create .zshrc file
cat << 'EOL' > ~/.zshrc
# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Ensure .local/bin is in PATH
export PATH="$HOME/.local/bin:$PATH"

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
source $ZSH/oh-my-zsh.sh

# Initialize Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Initialize zoxide
eval "$(zoxide init zsh)"

# The Fuck Plugin Configuration
eval "$(thefuck --alias)"

fuck-command-line() {
    local FUCK="$(THEFUCK_REQUIRE_CONFIRMATION=0 thefuck $(fc -ln -1 | tail -n 1) 2> /dev/null)"
    [[ -z $FUCK ]] && echo -n -e "\a" && return
    BUFFER=$FUCK
    zle end-of-line
}
zle -N fuck-command-line
# Define shortcut keys: [Esc] [Esc]
bindkey -M emacs '\e\e' fuck-command-line
bindkey -M vicmd '\e\e' fuck-command-line
bindkey -M viins '\e\e' fuck-command-line

# Set FZF to use bat for previews
export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always {}'"

# Functions
fzf_open() {
    local file
    file=$(fzf --prompt='Select a file: ')
    [ -n "$file" ] && xdg-open "$file"
}

# Alias for fzf_open
alias fz='fzf_open'

# Aliases for exa
alias ls='exa --icons'
alias ll='exa -l --icons'
alias la='exa -a --icons'
alias lla='exa -la --icons'
alias lt='exa --tree --icons'
alias llh='exa -lh --icons'
alias lld='exa -l --icons --dirs-only'

# Nala as default package manager
alias apt='sudo nala'

# Starship Prompt
eval "$(starship init zsh)"

# Add ~/.local/bin to PATH for thefuck
export PATH="$PATH:~/.local/bin/"
EOL

# Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s $(which zsh) $USER
fi

echo "Setup completed! Please restart your terminal or run 'zsh' to start using the new configuration."
