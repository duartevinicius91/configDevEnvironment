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
    # configDevEnvironment
    sudo snap install spotify vlc docker htop youtube-dl mysql-workbench-community
    sudo snap install intellij-idea-community --classic
    sudo snap install node --classic
    sudo apt-get install -y git openjdk-17-jdk curl
    sudo addgroup --system docker
    sudo adduser $USER docker
    newgrp docker
    sudo snap disable docker
    sudo snap enable docker
    mkdir ~/tools && cd ~/tools
    wget https://dlcdn.apache.org/maven/maven-3/3.9.3/binaries/apache-maven-3.9.3-bin.tar.gz
    wget https://downloads.gradle.org/distributions/gradle-8.2.1-bin.zip
    wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.7%2B7/OpenJDK17U-jdk_x64_alpine-linux_hotspot_17.0.7_7.tar.gz
    tar -xvf OpenJDK17U-jdk_x64_alpine-linux_hotspot_17.0.7_7.tar.gz
    tar -xvf apache-maven-3.9.3-bin.tar.gz
    unzip gradle-8.2.1-bin.zip
    echo "######### DEV ENV ########" >> ~/.bashrc 
    echo "export JAVA_HOME=~/tools/jdk-17.0.7+7" >> ~/.bashrc
    echo "export GRADLE_HOME=~/tools/gradle-8.2.1" >> ~/.bashrc
    echo "export MAVEN_HOME=~/tools/apache-maven-3.9.3" >> ~/.bashrc
    echo "export PATH=\$PATH:\$JAVA_HOME/bin:\$GRADLE_HOME/bin:\$MAVEN_HOME/bin" >> ~/.bashrc
    source ~/.bashrc
    sudo snap refresh
}
main
