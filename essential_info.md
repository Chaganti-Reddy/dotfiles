# Essential Information For Me In My System 😅

1. If you are dual-booting with windows then there might be problems with time in windows. To resolve that open cmd as admin in windows
    
    ```For 32 Bit System run     Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1```
    ```For 64 Bit System run     Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_QWORD /d 1```

2. If you are using compiler.nvim package in neovim, here are some packages to be installed for it to work for every language. 

    ```bash
    # paru -S --needed "gcc" "binutils" "dotnet-runtime" "dotnet-sdk" "aspnet-runtime" "mono" "jdk-openjdk" "dart" "kotlin" "elixir" "npm" "nodejs" "typescript" "make" "go" "nasm" "r" "nuitka" "python" "ruby" "perl" "lua" "pyinstaller" "swift-language" "flutter-bin" "gcc-fortran" "fortran-fpm-bin"
    ```

3. If you are installing docker then go through - https://karna-blog.netlify.app/posts/docker-login-cli/

4. If you are using zen-browser, for extra theming go through ~/dotfiles/Extras/Extras/Zen Browser/ folder and use them in ~/.zen/ use folder

5. If you are installing YTERMUSIC then go through - https://github.com/ccgauche/ytermusic/blob/master/README.md

6. If you are preferring YOUTUI instead of YTERMUSIC then just paste the cookie value into cookie.txt in config folder

7. Use ccrypt to encrypt and decrypt your files
