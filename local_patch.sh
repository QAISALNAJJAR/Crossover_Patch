#!/bin/bash

APP="/Applications/CrossOver.app"
MACOS_DIR="$APP/Contents/MacOS"

HOOK_SRC="./hook.dylib"
PCO_SRC="./pco.sh"

HOOK_DST="$MACOS_DIR/hook.dylib"
CROSSOVER_BIN="$MACOS_DIR/CrossOver"
BACKUP_BIN="$MACOS_DIR/CrossOver.o"

# check app exists
if [ ! -d "$APP" ]; then
    echo "CrossOver.app not found"
    exit 1
fi

# check local files
if [ ! -f "$HOOK_SRC" ]; then
    echo "hook.dylib missing"
    exit 1
fi

if [ ! -f "$PCO_SRC" ]; then
    echo "pco.sh missing"
    exit 1
fi

echo "copying hook.dylib..."
sudo cp "$HOOK_SRC" "$HOOK_DST"

echo "signing hook.dylib..."
sudo codesign -f -s - "$HOOK_DST"

# backup original binary once
if [ ! -f "$BACKUP_BIN" ]; then
    echo "creating backup..."
    sudo mv "$CROSSOVER_BIN" "$BACKUP_BIN"
fi

echo "installing launcher..."
sudo cp "$PCO_SRC" "$CROSSOVER_BIN"

sudo chmod +x "$CROSSOVER_BIN"

echo "signing original executable..."
sudo codesign -f -s - "$BACKUP_BIN"

echo "done"