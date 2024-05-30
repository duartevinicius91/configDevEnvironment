#!/bin/bash

#!/bin/bash

#bash <(wget -qO- https://raw.githubusercontent.com/duartevinicius91/configDevEnvironment/main/clean.sh)
set -euo pipefail

clean() {
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo rm -rf /tmp/*
    sudo rm -rf /var/cache/apt/archives/
    sudo apt-get clean -y
    sudo apt-get autoremove -y
    sudo apt-get autoremove -y --purge
    sudo apt-get autoclean -y
    npx npkill
 }
 
clean
