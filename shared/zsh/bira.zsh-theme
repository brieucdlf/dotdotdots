local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

if [[ $UID -eq 0 ]]; then
    local user_host='%{$terminfo[bold]$fg[red]%}%n@%m%{$reset_color%}'
    local user_symbol='#'
else
    local user_host='%{$terminfo[bold]$fg[blue]%}%n%{$reset_color%}'
    local user_symbol='$'
fi

local current_dir='%{$terminfo[bold]$fg[blue]%}%~%{$reset_color%}'
local git_branch='$(git_prompt_info)'
local rvm_ruby='$(ruby_prompt_info)'
local venv_prompt='$(virtualenv_prompt_info)'

local symbol_start='%{$fg[grey]%}┌─╼%{$reset_color%}'
local symbol_middle='%{$fg[grey]%}──╼%{$reset_color%}'
local symbol_end='%{$fg[grey]%}└─╼%{$reset_color%}'

local bracket_start='%{$terminfo[bold]$fg[grey]%}[%{$reset_color%}'
local bracket_end='%{$terminfo[bold]$fg[grey]%}]%{$reset_color%}'


ZSH_THEME_RVM_PROMPT_OPTIONS="i v g"

PROMPT="${symbol_start} ${bracket_start}${user_host}${bracket_end} ${symbol_middle} ${bracket_start}${current_dir}${bracket_end} ${git_branch} ${venv_prompt}
${symbol_end}%B ${user_symbol}%b "
RPROMPT="%B${return_code}%b"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$terminfo[bold]$fg[grey]%}──╼ [%{$reset_color%}%{$terminfo[bold]$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%{$terminfo[bold]$fg[grey]%}]%{$reset_color%}"

ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg[red]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="› %{$reset_color%}"

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%{$fg[green]%}‹"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="› %{$reset_color%}"
ZSH_THEME_VIRTUALENV_PREFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX
ZSH_THEME_VIRTUALENV_SUFFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX
