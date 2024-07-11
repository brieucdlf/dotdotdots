# Setup fzf
# ---------
if [[ ! "$PATH" == */$HOME/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/$HOME/.fzf/bin"
fi

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--border='rounded' --border-label='' --preview-window='border-rounded' --prompt='> ' \
--marker='>' --pointer='◆' --separator='.' --scrollbar='│' \
--layout='reverse' --info='right' --height=80%"
  

# Auto-completion
# ---------------
source "$HOME/.fzf/shell/completion.zsh"

# Key bindings
# ------------
source "$HOME/.fzf/shell/key-bindings.zsh"

# add fd-find on T command to avoid ignored files
export FZF_DEFAULT_COMMAND="fd --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

