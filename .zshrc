[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

# source
plug "$HOME/.config/zsh/aliases.zsh"
plug "$HOME/.config/zsh/exports.zsh"

# plugins
plug "zap-zsh/supercharge"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/vim"
plug "zsh-users/zsh-syntax-highlighting"
plug "esc/conda-zsh-completion"
plug "zap-zsh/fzf"
plug "hlissner/zsh-autopair"

# theme
plug "zap-zsh/zap-prompt"

export PATH="$HOME/.local/bin":$PATH

test -r "~/.dir_colors" && eval $(dircolors ~/.dir_colors)
