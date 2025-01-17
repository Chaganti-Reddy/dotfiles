# My fish config. Not much to see here; just some pretty standard stuff.

### ADDING TO THE PATH
# First line removes the path; second line sets it.  Without the first line,
# your path gets massive and fish becomes very slow.
#load_nvm > /dev/stderr
set -e fish_user_paths
set -U fish_user_paths /usr/bin $fish_user_paths
set -U fish_user_paths $HOME/.emacs.d/bin $HOME/Applications $fish_user_paths
set -U fish_user_paths $HOME/.local/go/bin $HOME/Applications $fish_user_paths
set -U fish_user_paths $HOME/.local/yarn/bin $HOME/Applications $fish_user_paths
set -U fish_user_paths /usr/local/bin/ $HOME/Applications $fish_user_paths
set -U fish_user_paths $HOME/.fnm $HOME/Applications $fish_user_paths

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

### EXPORT ###
set fish_greeting                                 # Supresses fish's intro message
set TERM "xterm-256color"                         # Sets the terminal type
#set -x EDITOR "/usr/bin/nvim"                 # $EDITOR use nvim in terminal
#set -x VISUAL "/usr/bin/nvim"              # $VISUAL use nvim in GUI mode
#set -x SUDO_EDITOR "/usr/bin/nvim"              # $VISUAL use nvim in GUI mode
set EDITOR "emacsclient -t -a ''"                 # $EDITOR use Emacs in terminal
set VISUAL "emacsclient -c -a emacs"              # $VISUAL use Emacs in GUI mode
set -x PATH "/usr/lib/R/" $PATH
set -x JAVA_HOME "/usr/lib/jvm/default/"

## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
  source ~/.fish_profile
end

#fzf
set fzf_preview_file_cmd cat
set fzf_preview_dir_cmd exa --all --color=always

### SET MANPAGER
### Uncomment only one of these!

### "bat" as manpager
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

### "vim" as manpager
# set -x MANPAGER '/bin/bash -c "vim -MRn -c \"set buftype=nofile showtabline=0 ft=man ts=8 nomod nolist norelativenumber nonu noma\" -c \"/normal L\" -c \"nmap q :qa<CR>\"</dev/tty <(col -b)"'

### "nvim" as manpager
# set -x MANPAGER "nvim -c 'set ft=man' -"

### SET EITHER DEFAULT EMACS MODE OR VI MODE ###
function fish_user_key_bindings
  fish_default_key_bindings
  # fish_vi_key_bindings
end
### END OF VI MODE ###

### AUTOCOMPLETE AND HIGHLIGHT COLORS ###
#set fish_color_normal brcyan
#set fish_color_autosuggestion '#7d7d7d'
#set fish_color_command brcyan
#set fish_color_error '#ff6c6b'
#set fish_color_param brcyan

### SPARK ###
set -g spark_version 1.0.0

complete -xc spark -n __fish_use_subcommand -a --help -d "Show usage help"
complete -xc spark -n __fish_use_subcommand -a --version -d "$spark_version"
complete -xc spark -n __fish_use_subcommand -a --min -d "Minimum range value"
complete -xc spark -n __fish_use_subcommand -a --max -d "Maximum range value"

function spark -d "sparkline generator"
    if isatty
        switch "$argv"
            case {,-}-v{ersion,}
                echo "spark version $spark_version"
            case {,-}-h{elp,}
                echo "usage: spark [--min=<n> --max=<n>] <numbers...>  Draw sparklines"
                echo "examples:"
                echo "       spark 1 2 3 4"
                echo "       seq 100 | sort -R | spark"
                echo "       awk \\\$0=length spark.fish | spark"
            case \*
                echo $argv | spark $argv
        end
        return
    end

    command awk -v FS="[[:space:],]*" -v argv="$argv" '
        BEGIN {
            min = match(argv, /--min=[0-9]+/) ? substr(argv, RSTART + 6, RLENGTH - 6) + 0 : ""
            max = match(argv, /--max=[0-9]+/) ? substr(argv, RSTART + 6, RLENGTH - 6) + 0 : ""
        }
        {
            for (i = j = 1; i <= NF; i++) {
                if ($i ~ /^--/) continue
                if ($i !~ /^-?[0-9]/) data[count + j++] = ""
                else {
                    v = data[count + j++] = int($i)
                    if (max == "" && min == "") max = min = v
                    if (max < v) max = v
                    if (min > v ) min = v
                }
            }
            count += j - 1
        }
        END {
            n = split(min == max && max ? "▅ ▅" : "▁ ▂ ▃ ▄ ▅ ▆ ▇ █", blocks, " ")
            scale = (scale = int(256 * (max - min) / (n - 1))) ? scale : 1
            for (i = 1; i <= count; i++)
                out = out (data[i] == "" ? " " : blocks[idx = int(256 * (data[i] - min) / scale) + 1])
            print out
        }
    '
end
### END OF SPARK ###


### FUNCTIONS ###
# Spark functions
function letters
    cat $argv | awk -vFS='' '{for(i=1;i<=NF;i++){ if($i~/[a-zA-Z]/) { w[tolower($i)]++} } }END{for(i in w) print i,w[i]}' | sort | cut -c 3- | spark | lolcat
    printf  '%s\n' 'abcdefghijklmnopqrstuvwxyz'  ' ' | lolcat
end

function commits
    git log --author="$argv" --format=format:%ad --date=short | uniq -c | awk '{print $1}' | spark | lolcat
end

# Functions needed for !! and !$
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end
# The bindings for !! and !$
if [ $fish_key_bindings = "fish_vi_key_bindings" ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# Function for creating a backup file
# ex: backup file.txt
# result: copies file as file.txt.bak
function backup --argument filename
    cp $filename $filename.bak
end

# Function for copying files and directories, even recursively.
# ex: copy DIRNAME LOCATIONS
# result: copies the directory and all of its contents.
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
	set from (echo $argv[1] | trim-right /)
	set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

# Function for printing a column (splits input on whitespace)
# ex: echo 1 2 3 | coln 3
# output: 3
function coln
    while read -l input
        echo $input | awk '{print $'$argv[1]'}'
    end
end

# Function for printing a row
# ex: seq 3 | rown 3
# output: 3
function rown --argument index
    sed -n "$index p"
end

# Function for ignoring the first 'n' lines
# ex: seq 10 | skip 5
# results: prints everything but the first 5 lines
function skip --argument n
    tail +(math 1 + $n)
end

# Function for taking the first 'n' lines
# ex: seq 10 | take 5
# results: prints only the first 5 lines
function take --argument number
    head -$number
end

function mkcd --argument dir
  mkdir -p $dir && cd $dir
end

function ctime --argument file
  g++ -std=c++17 $file".cpp" -o $file
  time ./$file
end

function mosscc --argument file1 file2
  perl -i ~/moss.pl -l cc $file1 $file2
end

function mosspy --argument file1 file2
  perl -i ~/moss.pl -l python $file1 $file2
end

### END OF FUNCTIONS ###


### ALIASES ###
# \x1b[2J   <- clears tty
# \x1b[1;1H <- goes to (1, 1) (start)
alias clear='echo -en "\x1b[2J\x1b[1;1H" ; echo; echo; seq 1 (tput cols) | sort -R | spark | lolcat; echo; echo'

alias archlinux-fix-keys="sudo pacman-key --init && sudo pacman-key --populate archlinux && sudo pacman-key --refresh-keys"

# root privileges
alias doas="doas --"

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# vim and emacs
alias vim='lvim'
alias em='/usr/bin/emacs -nw'
#alias emacs="emacsclient -c -a 'emacs'"
alias doomsync="~/.emacs.d/bin/doom sync"
alias doomdoctor="~/.emacs.d/bin/doom doctor"
alias doomupgrade="~/.emacs.d/bin/doom upgrade"
alias doompurge="~/.emacs.d/bin/doom purge"

# Changing "ls" to "exa"
alias ls='exa -al --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -l --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias l.='exa -a | egrep "^\."'
alias l+="xbacklight -inc"
alias l-="xbacklight -dec"
alias ip="ip -color"

alias cat='bat --style header --style snip --style changes --style header'

# pacman and yay
alias update='sudo pacman -Syu'                 # update only standard pkgs
#alias yaysua='yay -Sua --noconfirm'              # update only AUR pkgs (yay)
#alias yaysyu='yay -Syu --noconfirm'              # update standard pkgs and AUR pkgs (yay)
alias parsua='paru -Sua --noconfirm'             # update only AUR pkgs (paru)
alias parsyu='paru -Syu --noconfirm'             # update standard pkgs and AUR pkgs (paru)
alias unlock='sudo rm /var/lib/pacman/db.lck'    # remove pacman lock
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'  # remove orphaned packages

# get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias tarnow='tar -acf '
alias untar='tar -xvf '
alias wget='wget -c '

alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias hw='hwinfo --short'                                   # Hardware Info
alias big="expac -H M '%m\t%n' | sort -h | nl"              # Sort installed packages according to size in MB
#alias gitpkg='pacman -Q | grep -i "\-git" | wc -l'			# List amount of -git packages

alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

# adding flags
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
#alias lynx='lynx -cfg=~/.lynx/lynx.cfg -lss=~/.lynx/lynx.lss -vikeys'
#alias vifm='./.config/vifm/scripts/vifmrun'
#alias ncmpcpp='ncmpcpp ncmpcpp_directory=$HOME/.ncmpcpp/'
#alias mocp='mocp -M "$XDG_CONFIG_HOME"/moc -O MOCDir="$XDG_CONFIG_HOME"/moc'

# ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# Merge Xresources
#alias merge='xrdb -merge ~/.Xresources'

# git
alias gs='git status'
#alias addup='git add -u'
alias addall='git add .'
#alias branch='git branch'
#alias checkout='git checkout'
alias gc='git clone'
alias commit='git commit -m'
#alias fetch='git fetch'
alias pull='git pull origin'
alias push='git push origin'
#alias tag='git tag'
#alias newtag='git tag -a'

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# gpg encryption
# verify signature for isos
#alias gpg-check="gpg2 --keyserver-options auto-key-retrieve --verify"
# receive the key of a developer
#alias gpg-retrieve="gpg2 --keyserver-options auto-key-retrieve --receive-keys"

# youtube-dl
alias yta-aac="youtube-dl --extract-audio --audio-format aac "
alias yta-best="youtube-dl --extract-audio --audio-format best "
alias yta-flac="youtube-dl --extract-audio --audio-format flac "
alias yta-m4a="youtube-dl --extract-audio --audio-format m4a "
alias yta-mp3="youtube-dl --extract-audio --audio-format mp3 "
alias yta-opus="youtube-dl --extract-audio --audio-format opus "
alias yta-vorbis="youtube-dl --extract-audio --audio-format vorbis "
alias yta-wav="youtube-dl --extract-audio --audio-format wav "
alias ytv-best="youtube-dl -f bestvideo+bestaudio "

# switch between shells
# I do not recommend switching default SHELL from bash.
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"
alias tofish="sudo chsh $USER -s /bin/fish && echo 'Now log out.'"

# bare git repo alias for dotfiles
#alias config="/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME"

# termbin
#alias tb="nc termbin.com 9999"

# the terminal rickroll
#alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

# Unlock LBRY tips
#alias tips="lbrynet txo spend --type=support --is_not_my_input --blocking"

### DTOS ###
# Copy/paste all content of /etc/dtos over to home folder. A backup of config is created. (Be careful running this!)
#alias dtoscopy='[ -d ~/.config ] || mkdir ~/.config && cp -Rf ~/.config ~/.config-backup-(date +%Y.%m.%d-%H.%M.%S) && cp -rf /etc/dtos/* ~'
# Backup contents of /etc/dtos to a backup folder in $HOME.
#alias dtosbackup='cp -Rf /etc/dtos ~/dtos-backup-(date +%Y.%m.%d-%H.%M.%S)'

### RANDOM COLOR SCRIPT ###
# Get this script from my GitLab: gitlab.com/dwt1/shell-color-scripts
# Or install it from the Arch User Repository: shell-color-scripts
colorscript random

### SETTING THE STARSHIP PROMPT ###
#starship init fish | source
fnm env | source
zoxide init fish | source
alias svi="sudo nvim"
alias su="sudo fish"
alias r="radian"
#alias cl="clear"
alias grub-update="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias bspr="bspc wm -r"
alias jl="jupyter-lab"
alias brc="nvim ~/.config/bspwm/bspwmrc"
alias frc="nvim ~/.config/fish/config.fish"
alias prc="nvim ~/.config/bspwm/polybar/config"
alias xhs="nvim ~/.xmonad/xmonad.hs"
alias rrc="nvim ~/.config/ranger/rc.conf"
alias xmobar="nvim ~/.config/xmobar/dracula-xmobarrc"
alias nrc="nvim ~/.config/nvim/init.lua"
alias src="nvim ~/.config/sxhkd/sxhkdrc"
alias arc="nvim ~/.config/alacritty/alacritty.yml"
alias zrc="nvim ~/.config/zathura/zathurarc"
alias music="cd ~/Music/"
alias pict="cd ~/Pictures/"
alias dow="cd ~/Downloads/"
alias doc="cd ~/Documents/"
alias greenclear='greenclip clear'
alias sql="sudo mysql -u DSAI -p"
alias precompile="sudo g++ -std=c++17 stdc++.h"
alias grub="sudo lvim /etc/default/grub"
alias gpgkeys="gpg --list-secret-keys --keyid-format=long"
alias lock="betterlockscreen -l"
alias createvirtual2="virtualenv --python="/usr/bin/python2.7" "my_env""

## Starship prompt
#if status --is-interactive
  # source ("/usr/bin/starship" init fish --print-full-init | psub)
   #end
starship init fish | source

set -Ux FZF_DEFAULT_OPTS "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"

function gccr --argument repo
  git clone https://github.com/Chaganti-Reddy/$repo
end

function virtual --argument dir
  python3 -m virtualenv $dir
  source $dir/bin/activate.fish
end

function activate --argument dir 
  source $dir/bin/activate.fish
end

bind \cl 'clear; commandline -f repaint'
bind \cH 'backward-kill-path-component'

alias CP='cd /media/Files/CP'
alias vim='nvim'
