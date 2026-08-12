# Native interactive Zsh configuration.
source "$ZDOTDIR/options.zsh"
source "$ZDOTDIR/environment.zsh"
source "$ZDOTDIR/integrations.zsh"
source "$ZDOTDIR/history.zsh"
source "$ZDOTDIR/completion.zsh"

# shellcheck disable=SC1094
source "$ZDOTDIR/functions.zsh"
autoload -Uz zmv

source "$ZDOTDIR/keybindings.zsh"
source "$ZDOTDIR/prompt.zsh"
source "$ZDOTDIR/aliases.zsh"

# Third-party code is installed as XDG data, not mixed with this configuration.
typeset -g ZSH_PLUGIN_DIR="${ZSH_PLUGIN_DIR:-$XDG_DATA_HOME/zsh/plugins}"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'

if [[ -r "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Syntax highlighting must be loaded after all other ZLE configuration.
if [[ -r "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
