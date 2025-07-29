## PARU INSTALLATION
cd ~/Downloads
sudo pacman -S git
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si
cd ~/Downloads
rm -rf paru-bin
cd

## SYSTEM STUFF
paru -Syyu bash-completion tlp tlp-rdw git openssh curl wget system-config-printer base-devel intel-ucode bash-language-server btop fastfetch bat exa fd ripgrep fzf stow stylua tar tree time unrar unzip bluez bluez-utils brightnessctl xfsprogs ntfs-3g clang gcc clipnotify inotify-tools psutils yakuake e2fsprogs efibootmgrgc git-lfs gstreamer jq screenkey main lazygit lolcat sxiv shellcheck net-tools numlockx prettier progress zip rsync trash-cli pandoc python-pywal glow xarchiver man-db man-pages ncdu python-pip nwg-look zbar os-prober pamixer parallel shfmt tesseract tesseract-data-eng python-prctl vscode-css-languageserver ffmpegthumbnailer lua-language-server bmoc playerctl rmpc mpd mpv mpc poppler poppler-glib gnome-disk-utility gparted pavucontrol yad timeshift gnu-free-fonts go hugo hunspell hunspell-en_us imagemagick ueberzugpp luacheck mlocate translate-shell jdk-openjdk meld blueman newboat  dart-sass  speedtest-cli lynx atool figlet luarocks network-manager-applet glfw alsa-firmware sof-firmware alsa-ucm-conf viewnior qalculate-gtk pyright python-black vscode-html-languageserver typescript-language-server mdformat ydotool ccls jedi-language-server wakatime flatpak ghostscript qpdf mupdf-tools openssl dbus sqlite hspell nuspell dictd cargo xmlstartlet lua51 gdb yq dos2unix 7zip perl-image-exiftool python-psutil preload ttf-ms-fonts didyoumean-bin arch-wiki-docs sysstat lazydocker-bin gopls gopls gomodifytags gotests gore graphviz python-pyflakes python-isort python-pipenv python-nose python-pytest tidy stylelint js-beautify cpptools-debug-bin dialog python-watchdog advcpmv maven speech-dispatcher python-lsp-server system-config-printer python-plyer

sudo systemctl enable --now tlp.service
sudo systemctl enable --now bluetooth.service

## ZSH STUFF
sudo pacman -S zsh  zsh-completions zsh-autosuggestions zsh-syntax-highlighting zoxide

## VIM && NEOVIM && EMACS
sudo pacman -S vim neovim html-xml-utils aspell emacs tree-sitter-cli tree-sitter-bash tree-sitter-rust

## BROWSER && TORRENT STUFF
sudo pacman -S firefox aria2 python-adblock qutebrowser dnsmasq

## NAUTILUS STUFF
# sudo pacman -S gvfs gvfs-afc gvfs-google gvfs-goa gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-onedrive gvfs-smb tumbler thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman thunar-vcs-plugin

## GPG && ENCRYPTION STUFF
sudo pacman -S pass gnupg ccrypt  git-remote-gcrypt

## QEMU && VIRTUALIZATION STUFF
sudo pacman -S qemu-full libguestfs

## NODEJS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.zshrc
nvm install --lts

## THEMING STUFF
paru -S whitesur-cursor-theme-git

## ANIME && YT STUFF
paru -S fastanime-git yt-dlp-git

## FONTS STUFF
paru -S adobe-source-code-pro-fonts noto-fonts noto-fonts-cjk  noto-fonts-emoji ttf-hack ttf-jetbrains-mono ttf-ubuntu-font-family ttf-ubuntu-mono-nerd ttf-ubuntu-nerd ttf-opensans ttf-dejavu-nerd ttf-firacode-nerd otf-droid-nerd ttf-cascadia-code-nerd ttf-opensans ttf-hack-nerd ttf-ibmplex-mono-nerd ttf-jetbrains-mono-nerd ttf-ubuntu-mono-nerd ttf-roboto-mono-nerd otf-apple-fonts  ttf-material-design-icons-webfont ttf-iosevka-nerd ttf-iosevkaterm-nerd

# INSTALL HYPRLAND && SETUP
sudo pacman -S rofi-wayland rofi-emoji rofi-calc dunst udiskie tree-sitter-hyprlang hyprlang-ts-mode kitty yazi
