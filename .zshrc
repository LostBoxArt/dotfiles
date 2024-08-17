
# Path to your oh-my-zsh installation
ZSH="/home/jesus/.oh-my-zsh"

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

# Add Zed to PATH
export PATH="$PATH:/opt/zed"

# Initialize zoxide
eval "$(zoxide init zsh)"

# The Fuck Plugin Configuration
# Ensure that thefuck is installed and aliased
if command -v thefuck > /dev/null; then
    eval $(thefuck --alias)
else
    echo "thefuck is not installed or not in your PATH."
fi

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

# Functions
fzf_open() {
    local file
    file=$(fzf --preview 'batcat --style=numbers --color=always {}' --prompt='Select a file: ')
    [ -n "$file" ] && xdg-open "$file"
}

# Aliases for bat and cat
alias cat='batcat'          # Use batcat for cat command
alias batcat='cat'          # Use cat for batcat command

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
eval "$(starship init zsh)"