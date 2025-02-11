#!/bin/bash

set -e  # Exit on error
set -o pipefail
set -u  # Treat unset variables as errors

EMACS_DIR="$HOME/emacs-build"
LOG_FILE="/tmp/emacs_install.log"

echo "🔧 Starting Emacs build process..." | tee "$LOG_FILE"

# Function to check if a package is installed
is_installed() {
    pacman -Qq "$1" &>/dev/null
}

# ---- Step 1: Install Dependencies ----
echo "📦 Checking and installing dependencies..."

DEPENDENCIES=(
  base-devel git texinfo jansson gnutls librsvg
  libgccjit gcc libxml2 harfbuzz cairo freetype2
  libxpm libjpeg-turbo libpng giflib mupdf-tools poppler
)

for pkg in "${DEPENDENCIES[@]}"; do
    if is_installed "$pkg"; then
        echo "✅ $pkg is already installed." | tee -a "$LOG_FILE"
    else
        echo "📦 Installing $pkg..." | tee -a "$LOG_FILE"
        sudo pacman -S --needed --noconfirm "$pkg"
    fi
done

# ---- Step 2: Clone Emacs Source ----
if [ -d "$EMACS_DIR" ]; then
    echo "⚠️ Emacs source directory exists, removing it..." | tee -a "$LOG_FILE"
    rm -rf "$EMACS_DIR"
fi

echo "📥 Cloning Emacs repository..." | tee -a "$LOG_FILE"
git clone --depth=1 https://git.savannah.gnu.org/git/emacs.git "$EMACS_DIR"
cd "$EMACS_DIR"

# ---- Step 3: Configure Emacs ----
echo "⚙️ Configuring Emacs..." | tee -a "$LOG_FILE"
./autogen.sh
./configure --with-x-toolkit=lucid --with-native-compilation --without-imagemagick 2>&1 | tee -a "$LOG_FILE"

# ---- Step 4: Compile Emacs ----
echo "🚀 Compiling Emacs... (This may take a while)" | tee -a "$LOG_FILE"
make -j$(nproc) 2>&1 | tee -a "$LOG_FILE"

# ---- Step 5: Install Emacs ----
echo "📌 Installing Emacs..." | tee -a "$LOG_FILE"
sudo make install 2>&1 | tee -a "$LOG_FILE"

# ---- Step 6: Verify Installation ----
echo "✅ Verifying Emacs installation..." | tee -a "$LOG_FILE"

if command -v emacs >/dev/null 2>&1; then
    echo "🎉 Emacs installed successfully!" | tee -a "$LOG_FILE"
    echo "🛠️ Checking build options:" | tee -a "$LOG_FILE"
    emacs --batch --eval '(print system-configuration-options)' | tee -a "$LOG_FILE"

    # ---- Step 7: Cleanup ----
    echo "🧹 Cleaning up build files..."
    rm -rf "$EMACS_DIR"
    echo "✅ Build directory removed!"
else
    echo "❌ Emacs installation failed!" | tee -a "$LOG_FILE"
    exit 1
fi

echo "🎯 Build complete! Run 'emacs' to start." | tee -a "$LOG_FILE"
