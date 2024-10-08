# lines_to_append="ILoveCandy\nParallelDownloads=10\nColor"
# sudo sed -i '/^\[options\]/a '"$lines_to_append" /etc/pacman.conf

# mkdir Downloads Documents Music Videos Pictures Desktop Git
# Update the system
# sudo pacman -Syu archlinux-keyring --noconfirm

# 1. Install essential packages
# sudo pacman -S base-devel intel-ucode git vim zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting bash-completion openssh wget curl htop neofetch bat exa fd ripgrep fzf stow stylua tar tree time acpilight aria2 unrar unzip bluez bluez-utils brightnessctl xfsprogs ntfs-3g clang gcc clipmenu clipnotify inotify-tools psutils dunst e2fsprogs gvfs gvfs-afc gvfs-google gvfs-goa gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-onedrive gvfs-smb efibootmgr zoxide gc git-lfs gnome-keyring polkit-gnome pass udiskie gstreamer jq xdotool screenkey xorg-xprop lazygit lolcat sxiv shellcheck net-tools numlockx prettier progress zip rsync lightdm-gtk-greeter trash-cli tlp tlp-rdw neovim xorg-xinput xclip xcompmgr xorg-xrandr xorg-xsetroot xsel xwallpaper pandoc starship python-pywal glow xarchiver xfce4-clipman-plugin qemu-full libguestfs xorg-xman man-db man-pages ncdu python-adblock dnsmasq python-pip lxappearance python-prctl vscode-css-languageserver ffmpegthumbnailer virt-manager spice-vdagent lua-language-server pass pinentry gnupg pass-otp zbar xorg-xlsclients xscreensaver os-prober qt6ct pamixer parallel --noconfirm

# sudo apt-get install  kitty rofi build-essential libx11-dev lm-sensors libxinerama-dev sharutils suckless-tools libxft-dev libc6 feh # for dwm in debian systems
# sudo apt-get install xcb libxcb-xkb-dev x11-xkb-utils libx11-xcb-dev libxkbcommon-x11-dev libxcb-res0-devlibharfbuzz-dev libharfbuzz-dev

# Using XFCE4-CLIPMAN for clipboard manager

# 2. Install yay 
# git clone https://aur.archlinux.org/yay.git
# cd yay
# makepkg -si
# cd ..
# rm -rf yay

# 3. Install AUR packages
# yay -S  brave-bin ccrypt didyoumean-git github-desktop-bin visual-studio-code-bin preload peerflix webtorrent-cli webtorrent-mpv-hook git-remote-gcrypt sublime-text-4 --noconfirm

# 4. Install GUI packages
# sudo pacman -S baobab gnome-disk-utility flameshot bc docker docker-compose docker-scan gparted libreoffice-fresh pavucontrol qutebrowser ranger yad timeshift --noconfirm

# 5. Install multimedia packages
# sudo pacman -S mpv mpc mpd ncmpcpp mplayer poppler poppler-glib --noconfirm && yay -S ferdium-bin --noconfirm

# 6. Install fonts 
# sudo pacman -S adobe-source-code-pro-fonts noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-hack ttf-jetbrains-mono ttf-ubuntu-font-family ttf-ubuntu-mono-nerd ttf-ubuntu-nerd ttf-opensans gnu-free-fonts --noconfirm && yay -S ttf-ms-fonts --noconfirm

# 7. Install external packages
# yay -S ani-cli-git arch-wiki-docs ytfzf-git  --noconfirm
# yay -S walogram-git docker-desktop # Optional
# sudo pacman -S yt-dlp hugo hunspell hunspell-en_us imagemagick ueberzug luacheck mlocate newsboat nodejs npm texlive-bin texlive-meta texlive-latex texlive-basic translate-shell --noconfirm

# 8. Mariadb setup
# sudo pacman -S mariadb --noconfirm
# sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
# sudo systemctl enable --now mariadb
# sudo mariadb-secure-installation

# 9. Enable services
# sudo updatedb
# sudo mandb
# sudo systemctl enable --now tlp
# sudo systemctl enable --now bluetooth.service
# sudo systemctl enable lightdm.service
# sudo systemctl enable --now libvirtd

# 10. Permissions
# sudo usermod -aG docker $USER
# sudo usermod -aG video $USER
# sudo usermod -aG libvirt $USER
# sudo virsh net-start default
# For VM sharing https://docs.getutm.app/guest-support/linux/

# 11. Setup git 
# git config --global user.name "Chaganti-Reddy"
# git config --global user.email "chagantivenkataramireddy4@gmail.com"

# 12. Alternatives & Optionals:
# 1. Install Java 
# sudo pacman -S jdk-openjdk openjdk-doc openjdk-src --noconfirm
# 2. Install qbit torrent
# sudo pacman -S qbittorrent --noconfirm
# 4. Install Teamviewer
# yay -S teamviewer --noconfirm
# 5. Install Zathura
# sudo pacman -S zathura zathura-pdf-mupdf zathura-djvu zathura-ps zathura-cb --noconfirm && yay -S zathura-pywal-git --noconfirm
# also install pywal zathura in ~/dotfiles/Extras/Extras/Zathura-Pywal-master/
# 8. Install Thunar
# sudo pacman -S thunar thunar-archive-plugin thunar-volman thunar-media-tags-plugin --noconfirm
# 8. Install GTK theme and QT theme
# yay -S elementary-icon-theme --noconfirm # Previously used icons
# yay -S  gruvbox-dark-gtk whitesur-icon-theme  whitesur-cursor-theme-git kvantum kvantum-theme-otto-git && sudo pacman -S gtk-engine-murrine --noconfirm
# 15. Install MINICONDA
# wget https://repo.anaconda.com/miniconda/Miniconda3-py310_24.3.0-0-Linux-x86_64.sh
# sh Miniconda3-py310_24.3.0-0-Linux-x86_64.sh
# rm Miniconda3-py310_24.3.0-0-Linux-x86_64.sh
# 9. Install anipy-cli 
# pip install anipy-cli
# 10. Install Doom Emacs 
# sudo pacman -S emacs --noconfirm && git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs && ~/.config/emacs/bin/doom install # Later run doom sync
# After that run ---- M-x nerd-icons-install-fonts 
# 11. Insatll waldl from Extras folder of dotfiles
# cd  ~/dotfiles/Extras/Extras/waldl-master/ && sudo make install && cd ~/dotfiles
# 12. Install ollama from Extras folder of dotfiles
# sh ~/dotfiles/Extras/Extras/ollama.sh
# ollama serve
# ollama pull mistral
# ollama pull gemma:7b
# 13. Install brave Extensions
# brave://extensions/ ---> Install Comp Companion, uBlock Origin, GFG to Github, Google Translate, LeetHub, User-Agent switcher
# 14. Install Bash Language Server
# sudo npm i -g bash-language-server
# 15. Setup zsh shell as default
# chsh -s /bin/zsh
# 16. Install oh-my-zsh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# exit # exit from zsh
# 17. Install floorp instead of firefox 
# yay -S floorp-bin firefox-pwa-bin --noconfirm
# yay -S python-pywalfox --noconfirm 
# 18. Use dmenu for network manager (Optional)
# yay -S networkmanager-dmenu-git 
# 19. Install Blender for Video Editing
# sudo pacman -S blender --noconfirm
# 20. Install OBS Studio for Screen Recording
# sudo pacman -S obs-studio --noconfirm
# 21. Install GIMP for Image Editing
# sudo pacman -S gimp --noconfirm
# 22. Install Inkscape for Vector Graphics
# sudo pacman -S inkscape --noconfirm
# 23. Install Octave for Numerical Computing
# sudo pacman -S octave --noconfirm  
# 24. Install blueman if needed for bluetooth manager 
# sudo pacman -S blueman --noconfirm 

# 13. Move Respective files to root directory
# sudo cp ~/dotfiles/Extras/Extras/usr/share/xsessions/dwm.desktop /usr/share/xsessions
# # sudo cp -r ~/dotfiles/Extras/Extras/boot/grub/themes/mocha /boot/grub/themes/
# sudo cp -r ~/dotfiles/Extras/Extras/boot/grub/themes/tartarus/ /boot/grub/themes/
# Now edit the grub config file
# sudo cp ~/dotfiles/Extras/Extras/etc/bash.bashrc /etc/
# sudo cp ~/dotfiles/Extras/Extras/etc/DIR_COLORS /etc/
# sudo cp ~/dotfiles/Extras/Extras/etc/mpd.conf /etc/
# sudo cp ~/dotfiles/Extras/Extras/etc/nanorc /etc/
# sudo cp ~/dotfiles/Extras/Extras/etc/environment /etc/
# sudo cp -r ~/dotfiles/Extras/Extras/etc/lightdm/ /etc/
# cp ~/dotfiles/Extras/Extras/alanpeabody.zsh-theme ~/.oh-my-zsh/themes/
# mkdir ~/.icons && cp -r ~/dotfiles/Extras/Extras/.icons/Capitaine/ ~/.icons/

# 16. Install Fonts
# mkdir ~/.local/share/fonts/
# git clone https://github.com/Chaganti-Reddy/my-fonts.git
# mv my-fonts ~/.local/share/fonts/

# 17. Install/stow dotfiles
# First check for conflicts
 #rm -rf ~/.config/doom
# rm -rf ~/.config/gtk-3.0
# rm ~/.bashrc
# rm ~/.zshrc
# cd ~/dotfiles
# stow */

# 18. Install DWM
# cd ~/.config/dwm && sudo make clean install && cd
# cd ~/.config/slstatus && sudo make clean install && cd
# cd ~/.config/st && sudo make install && cd
# cd ~/.config/dmenu && sudo make install && cd

# 19. Install Stockfish
# wget https://github.com/official-stockfish/Stockfish/releases/latest/download/stockfish-ubuntu-x86-64-avx2.tar
# tar -xvf stockfish-ubuntu-x86-64-avx2.tar
# rm stockfish-ubuntu-x86-64-avx2.tar
# mv stockfish ~/

# Install python packages 
# pip install pynvim numpy pandas matplotlib seaborn scikit-learn jupyterlab ipykernel ipywidgets tensorflow python-prctl inotify-simple psutil opencv-python keras mov-cli-youtube mov-cli mov-cli-test otaku-watcher film-central 
# pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu # pytorch cpu version 


### HYPRLAND

# sudo pacman -S kitty hyprland system-config-printer hyprpicker hyprlock chafa hypridle waybar wl-clipboard speech-dispatcher hyprpaper brightnessctl cmake meson cpio grim slurp rofi-wayland wf-recorder
# yay -S wlrobs-hg clipse hyde-cli-git wlogout
# sudo pacman -S wofi
# git clone https://github.com/dracula/wofi.git
# sudo pacman -S thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman thunar-vcs-plugin 
