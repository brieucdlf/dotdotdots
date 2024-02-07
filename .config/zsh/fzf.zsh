# Setup fzf
# ---------
if [[ ! "$PATH" == */$HOME/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/$HOME/.fzf/bin"
fi

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#d0d0d0,fg+:#d0d0d0,bg:#282828,bg+:#262626
  --color=hl:#83A598,hl+:#B8BB26,info:#FABD2F,marker:#83A598
  --color=prompt:#FABD2F,spinner:#FB4934,pointer:#B8BB26,header:#87afaf
  --color=border:#262626,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker=">" --pointer="◆" --separator="." --scrollbar="│"
  --layout="reverse" --info="right" --height=80%'
  

# Auto-completion
# ---------------
source "$HOME/.fzf/shell/completion.zsh"

# Key bindings
# ------------
source "$HOME/.fzf/shell/key-bindings.zsh"

# add fd-find on T command to avoid ignored files
export FZF_DEFAULT_COMMAND="fd --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

