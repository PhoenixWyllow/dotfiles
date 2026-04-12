# Use powerline
USE_POWERLINE="false"
# Has weird character width
# Example:
#    is not a diamond
HAS_WIDECHARS="false"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
# if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
#   source /usr/share/zsh/manjaro-zsh-prompt
# fi

eval "$(starship init zsh)"

# Neovim dev mode function (run from dotfiles repo root)
nvim-dev() {
  local xdg_config="${PWD}/config"
  local xdg_data="${PWD}/.devstate/data"
  local xdg_state="${PWD}/.devstate/state"
  local xdg_cache="${PWD}/.devstate/cache"
  XDG_CONFIG_HOME="$xdg_config" XDG_DATA_HOME="$xdg_data" XDG_STATE_HOME="$xdg_state" XDG_CACHE_HOME="$xdg_cache" nvim "$@"
}
