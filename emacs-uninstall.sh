#!/bin/bash

set -e  # Exit on error
set -o pipefail
set -u  # Treat unset variables as errors

echo "🗑️ Uninstalling Emacs and cleaning up..."

# Step 1: Remove Emacs system-wide files
echo "🗑️ Removing installed Emacs binaries..."
sudo rm -rf /usr/local/bin/emacs
sudo rm -rf /usr/local/share/emacs
sudo rm -rf /usr/local/lib/emacs
sudo rm -rf /usr/local/include/emacs*
sudo rm -rf /usr/local/libexec/emacs
sudo rm -rf /usr/local/etc/emacs

# Step 2: Remove user-specific Emacs files
echo "🗑️ Removing user Emacs config and cache..."
rm -rf ~/.emacs.d
rm -rf ~/.config/emacs
rm -rf ~/.cache/emacs
rm -rf ~/.emacs

# Step 3: Verify uninstallation
if command -v emacs >/dev/null 2>&1; then
    echo "⚠️ Emacs is still detected! Check manually for leftover files."
else
    echo "✅ Emacs has been completely removed."
fi
