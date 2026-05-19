#!/bin/bash

echo "Crossover Patch Manager"
echo "======================="
echo "1) Apply Patch"
echo "2) Uninstall Patch"
echo "3) Exit"

read -r -p "Enter your choice [1-3]: " choice </dev/tty

case "$choice" in
    1)
        echo "Downloading and running patch script..."
        curl -fsSL https://raw.githubusercontent.com/QAISALNAJJAR/Crossover_Patch/main/patch.sh | bash
        ;;
    2)
        echo "Downloading and running uninstall script..."
        curl -fsSL https://raw.githubusercontent.com/QAISALNAJJAR/Crossover_Patch/main/uninstall.sh | bash
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Please select 1, 2, or 3."
        exit 1
        ;;
esac