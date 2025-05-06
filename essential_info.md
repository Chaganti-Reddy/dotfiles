# Essential Information For Me In My System 😅

1. If you are dual-booting with windows then there might be problems with time in windows. To resolve that open cmd as admin in windows
    
    ```For 32 Bit System run     Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1```
    ```For 64 Bit System run     Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_QWORD /d 1```

2. If you are using compiler.nvim package in neovim, here are some packages to be installed for it to work for every language. 

    ```bash
    # paru -S --needed "gcc" "binutils" "dotnet-runtime" "dotnet-sdk" "aspnet-runtime" "mono" "jdk-openjdk" "dart" "kotlin" "elixir" "npm" "nodejs" "typescript" "make" "go" "nasm" "r" "nuitka" "python" "ruby" "perl" "lua" "pyinstaller" "swift-language" "flutter-bin" "gcc-fortran" "fortran-fpm-bin"
    ```

3. If you are installing docker then go through - https://karnablog.netlify.app/docker-cli/

4. If you are using zen-browser, for extra theming go through ~/dotfiles/Extras/Extras/Zen Browser/ folder and use them in ~/.zen/ use folder

5. If you are installing YTERMUSIC then go through - https://github.com/ccgauche/ytermusic/blob/master/README.md

6. If you are preferring YOUTUI instead of YTERMUSIC then just paste the cookie value into cookie.txt in config folder

7. Use ccrypt to encrypt and decrypt your files

8. If you are installing my nvim config then first change the theme name in ~/.config/nvim/lua/chadrc.lua file to something like `nightowl` then after successfully loading all the plugins and if you have pywal setup then change the theme name back to `chadwal`.

9. If you want to remove password saving in browser then go throught - https://chagantireddy.netlify.app/post/pass-setup/

10. `Note- This is for me` - Install Brave Extension - unhook, copyfish, Leetcode Video Solutions, LeetHub V2, Simplify Copilot 

11. If you are using Brave Browser then go to `brave://flags/#ozone-platform-hint` and make it auto.

12. If you are using Vivaldi browser then go to `vivaldi://flags/#ozone-platform-hint` and make it auto and also go to `chrome://settings` and turn on gtk for dark context menus. Also if you want custom fonts in titlebars which is not available by default then just go to `vivaldi:experiments` and turn on Allow CSS modifications & just stow the vivaldi folder from dotfiles. After just upload the path of Default/Themes folder to Appearance settings.

13. If spotdl not working and getting errors like "FFmpegError: Failed to convert" then just change the value of "bitrate":null to "bitrate":"192k" - taken from https://github.com/spotDL/spotify-downloader/issues/1938#issuecomment-2753157035
