[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

# source
plug "$HOME/.config/zsh/aliases.zsh"
plug "$HOME/.config/zsh/exports.zsh"
plug "$HOME/.config/zsh/nvm.zsh"

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

# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# add custom nord theme colors
test -r "~/.dir_colors" && eval $(dircolors ~/.dir_colors)

# enable kubectl completion
source <(kubectl completion zsh)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Load Angular CLI autocompletion.
source <(ng completion script)
