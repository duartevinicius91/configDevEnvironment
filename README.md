#!/bin/bash

#bash <(wget -qO- https://raw.githubusercontent.com/duartevinicius91/configDevEnvironment/main/README.md)
set -euo pipefail

# Disables Ubuntu shortcuts that clash with IntelliJ Idea (and probably other
# Jetbrain products).
#
# Creates a backup file to restore the previous settings. To not have some
# shortcuts disabled, comment them out in the `KEYS` array.
#
# Tested on : Ubuntu 15.10
# Author    : Jonas Gröger <jonas.groeger@posteo.de>

readonly BACKUP_FILE="undo-fix-shortcuts-$(date +%s%N).sh"
readonly KEYS=(
    "/org/gnome/desktop/wm/keybindings/toggle-shaded"
    "/org/gnome/settings-daemon/plugins/media-keys/screensaver"
    "/org/gnome/settings-daemon/plugins/media-keys/terminal"
    "/org/gnome/desktop/wm/keybindings/switch-to-workspace-down"
    "/org/gnome/desktop/wm/keybindings/switch-to-workspace-up"
    "/org/gnome/desktop/wm/keybindings/switch-to-workspace-left"
    "/org/gnome/desktop/wm/keybindings/switch-to-workspace-right"
    "/org/gnome/desktop/wm/keybindings/begin-move"
    "/org/gnome/desktop/wm/keybindings/begin-resize"
    # To disable resetting a value, just comment out the line
)
readonly DISABLED_VALUE="['disabled']"

main() {
    sudo apt-get update -y
    sudo apt-get upgrade -y
    # Make backup
    printf "#!/bin/bash\n" >>  "$BACKUP_FILE"
    for key in "${KEYS[@]}"; do
        local value
        value=$(dconf read "$key")
        printf "dconf write \"%s\" \"%s\"\n" "$key" "$value" >> "$BACKUP_FILE"
    done

    # Disable all Ubuntu shortcuts
    for key in "${KEYS[@]}"; do
        dconf write "$key" "$DISABLED_VALUE"
    done

    # Add Docker's official GPG key:
    sudo apt-get install -y git ca-certificates curl gnupg

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Add the repository to Apt sources:
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # configDevEnvironment
    sudo snap install spotify vlc htop youtube-dl mysql-workbench-community
    sudo snap install intellij-idea-community --classic
    sudo snap install node --classic
    sudo snap refresh
}
main
