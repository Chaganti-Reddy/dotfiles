# Exports
export MANPATH="/usr/local/man:$MANPATH"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export LANG=en_US.UTF-8
# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
export EDITOR='/usr/bin/nvim'
export VISUAL='nvim'
export BROWSER='/usr/bin/firefox'
export PATH="$HOME/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.config/scripts/:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.config/rofi/scripts:$PATH"
export PATH="$HOME/miniconda:$PATH"
export JAVA_HOME="/usr/lib/jvm/default"
export PATH="$JAVA_HOME/bin:$PATH"
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
export PUPPETEER_EXECUTABLE_PATH="/home/karna/.cache/puppeteer/chrome-headless-shell/linux-133.0.6943.53/chrome-headless-shell-linux64/chrome-headless-shell"
export SUDO_EDITOR=/usr/bin/nvim
export FZF_DEFAULT_OPTS="--layout=reverse --exact --border=bold --border=rounded --margin=3% --color=dark"
export STARSHIP_LOG="error"
export MPLBACKEND=TkAgg
export EDITOR='/usr/bin/nvim'
export PAGER='bat'
# Lazy-load NVM only when needed
export NVM_DIR="$HOME/.nvm"

# echo some artwork 
# if [ -f "$HOME/.config/scripts/unix" ]; then
  # ~/.config/scripts/unix
# fi

