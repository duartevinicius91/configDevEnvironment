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
    sudo apt-get install -y curl ca-certificates
    # Make backup
    #printf "#!/bin/bash\n" >>  "$BACKUP_FILE"
    #for key in "${KEYS[@]}"; do
    #    local value
    #    value=$(dconf read "$key")
    #    printf "dconf write \"%s\" \"%s\"\n" "$key" "$value" >> "$BACKUP_FILE"
    #done

    # Disable all Ubuntu shortcuts
    #for key in "${KEYS[@]}"; do
    #    dconf write "$key" "$DISABLED_VALUE"
    #done

    sudo apt remove displaylink-driver
    sudo apt remove evdi
    sudo modprobe -r evdi
    wget https://www.synaptics.com/sites/default/files/Ubuntu/pool/stable/main/all/synaptics-repository-keyring.deb
    sudo apt install -y ./synaptics-repository-keyring.deb 
    sudo apt update && sudo apt install -y evdi-dkms displaylink-driver
    sh <(wget -qO- https://get.docker.com)
    
    # configDevEnvironment
    sudo snap install spotify vlc htop youtube-dl postman dbeaver-ce
    sudo snap install intellij-idea-community --classic
    sudo snap install node --classic
   
    sudo snap refresh
}
baixar_certificado() {
    local url=$1
    local porta=${2:-443}  # Usa 443 como porta padrão

    # Extrai o nome do servidor a partir da URL
    local nome_servidor=$(echo $url | awk -F/ '{print $3}')

    # Baixa o certificado e salva no diretório de certificados
    openssl s_client -showcerts -verify 5 -connect ${nome_servidor}:${porta} < /dev/null |
    awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; out="cert"a".crt"; print >out}'
    mv *.crt /usr/local/share/ca-certificates

    # Atualiza os certificados do sistema
    update-ca-certificates

    rm /usr/local/share/ca-certificates/*.crt
}
main
