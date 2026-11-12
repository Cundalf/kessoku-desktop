# Extra opcional: basado en el runbook y el prompt actual, sin cargar ~/.zshrc.
[[ -o interactive ]] || return
export KESSOKU_TERMINAL_ROOT="${ZDOTDIR:A:h}"
export STARSHIP_CONFIG="$KESSOKU_TERMINAL_ROOT/starship.toml"
local_state=${XDG_STATE_HOME:-$HOME/.local/state}/kessoku-terminal
mkdir -p "$local_state"
HISTFILE="$local_state/history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE INC_APPEND_HISTORY AUTO_CD
command -v dircolors >/dev/null && eval "$(dircolors -b)"
fpath=("$KESSOKU_TERMINAL_ROOT/plugins/zsh-completions/src" $fpath)
autoload -Uz compinit
compinit -d "$local_state/zcompdump-$ZSH_VERSION"
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
source "$KESSOKU_TERMINAL_ROOT/plugins/fzf-tab/fzf-tab.plugin.zsh"
source "$KESSOKU_TERMINAL_ROOT/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
if command -v fzf >/dev/null; then eval "$(fzf --zsh)"; fi
if command -v eza >/dev/null; then
 alias ls='eza --icons --group-directories-first'
 alias ll='eza -lh --icons --group-directories-first'
 alias la='eza -lah --icons --group-directories-first'
 alias tree='eza --tree --icons'
fi
command -v batcat >/dev/null && alias cat='batcat --paging=never'
alias grep='grep --color=auto'
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"
# Debe ir después de los demás widgets ZLE.
source "$KESSOKU_TERMINAL_ROOT/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ ${KESSOKU_NO_FETCH:-0} == 1 ]] || { command -v fastfetch >/dev/null && fastfetch; }
unset local_state
