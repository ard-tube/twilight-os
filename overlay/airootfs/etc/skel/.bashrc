# Twilight OS live user bash configuration
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -lAh --color=auto'
alias grep='grep --color=auto'
alias neofetch='fastfetch'

# Custom prompt with Twilight OS branding
PS1='\[\033[01;35m\]\u@twilight-os\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Run fastfetch on initial interactive terminal session
if [[ -z "$VTE_VERSION" ]] && [[ "$SHLVL" -le 2 ]]; then
    fastfetch
fi
