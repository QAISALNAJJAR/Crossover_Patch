#!/bin/bash

APP="/Applications/CrossOver.app"
MACOS_DIR="$APP/Contents/MacOS"

HOOK_DST="$MACOS_DIR/hook.dylib"
CROSSOVER_BIN="$MACOS_DIR/CrossOver"
BACKUP_BIN="$MACOS_DIR/CrossOver.o"

# check app exists
if [ ! -d "$APP" ]; then
    echo "CrossOver.app not found"
    echo "Please make sure CrossOver is installed in /Applications"
    exit 1
fi

# check for full disk access
if [ ! -r "/Library/Application Support/com.apple.TCC/TCC.db" ]; then
    echo "Error: Full Disk Access is required."
    echo "Please grant Full Disk Access to your terminal application:"
    echo "   System Settings > Privacy & Security > Full Disk Access"
    echo "   Add Terminal (or your terminal app) to the list"
    exit 1
fi

# Check if we are in a git repo of the patch
if [ -d ".git" ]; then
    echo "Git repository detected."
    # Check for updates from GitHub repo
    if git ls-remote https://github.com/QAISALNAJJAR/Crossover_Patch.git >/dev/null 2>&1; then
        echo "GitHub repo is accessible."
        echo "Fetching updates from GitHub..."
        # Fetch the latest from the main branch
        git fetch https://github.com/QAISALNAJJAR/Crossover_Patch.git main
        # Check if there are any changes
        if git diff --quiet HEAD FETCH_HEAD; then
            echo "Already up to date."
        else
            echo "Updates found. Updating local files..."
            git reset --hard FETCH_HEAD
            echo "Updated successfully. Please re-run the script to apply the updates."
            exit 0
        fi
    else
        echo "################################################################"
        echo "Repo is removed, Follow QAISALNAJJAR to fix it"
        echo "################################################################"
    fi
else
    # Mode 2: not a git repo (e.g., one-liner via curl)
    echo "Downloading latest hook.m and pco.sh from GitHub..."
    # Download hook.m
    if ! curl -fsSL -o hook.m https://raw.githubusercontent.com/QAISALNAJJAR/Crossover_Patch/main/hook.m; then
        echo "Failed to download hook.m. Trying to use local copy if available..."
        if [ ! -f "hook.m" ]; then
            echo "hook.m not found and cannot download. Please check your internet connection."
            exit 1
        fi
    fi

    # Download pco.sh
    if ! curl -fsSL -o pco.sh https://raw.githubusercontent.com/QAISALNAJJAR/Crossover_Patch/main/pco.sh; then
        echo "Failed to download pco.sh. Trying to use local copy if available..."
        if [ ! -f "pco.sh" ]; then
            echo "pco.sh not found and cannot download. Please check your internet connection."
            exit 1
        fi
    fi
fi

# Ensure we have hook.m and pco.sh
if [ ! -f "hook.m" ]; then
    echo "hook.m not found. Please ensure hook.m is present."
    exit 1
fi

if [ ! -f "pco.sh" ]; then
    echo "pco.sh not found. Please ensure pco.sh is present."
    exit 1
fi

# Check and build hook.dylib if missing or outdated
if [ ! -f "hook.dylib" ] || [ "hook.m" -nt "hook.dylib" ]; then
    echo "Building hook.dylib from hook.m..."
    if clang -dynamiclib -framework Foundation -framework AppKit -o hook.dylib hook.m; then
        echo "Successfully built hook.dylib"
    else
        echo "Failed to build hook.dylib"
        echo "Please check hook.m for errors and ensure clang is installed"
        exit 1
    fi
fi

# Set source files
HOOK_SRC="./hook.dylib"
PCO_SRC="./pco.sh"

echo "copying hook.dylib..."
if ! sudo cp "$HOOK_SRC" "$HOOK_DST"; then
    echo "Failed to copy hook.dylib"
    echo "Please check permissions and try again"
    exit 1
fi

echo "signing hook.dylib..."
if ! sudo codesign -f -s - "$HOOK_DST"; then
    echo "Failed to sign hook.dylib"
    echo "Please check if codesign is available and try again"
    exit 1
fi

# backup original binary once
if [ ! -f "$BACKUP_BIN" ]; then
    echo "creating backup..."
    if ! sudo mv "$CROSSOVER_BIN" "$BACKUP_BIN"; then
        echo "Failed to create backup of CrossOver binary"
        echo "Please check permissions and try again"
        exit 1
    fi
fi

echo "installing launcher..."
if ! sudo cp "$PCO_SRC" "$CROSSOVER_BIN"; then
    echo "Failed to install launcher"
    echo "Please check permissions and try again"
    exit 1
fi

sudo chmod +x "$CROSSOVER_BIN"

echo "signing original executable..."
if ! sudo codesign -f -s - "$BACKUP_BIN"; then
    echo "Failed to sign original executable"
    echo "Please check if codesign is available and try again"
    exit 1
fi

echo "Patch applied successfully! You can now run CrossOver as usual. with the patch :) and enjoy!"