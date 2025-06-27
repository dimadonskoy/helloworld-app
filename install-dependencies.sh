#!/usr/bin/env bash

#######################################################################     

#Developed by : Dmitri Donskoy
#Purpose : Install dependencies
#Update date : 27.06.2025
#Version : 0.0.1
# set -x
set -o errexit
set -o nounset
set -o pipefail


############################ GLOBAL VARS ##############################
# Check if user is root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Check if OS is Ubuntu or debian based 

# shellcheck source=/etc/os-release
source /etc/os-release

if [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"debian"* ]]; then
    echo
else
    echo "This is NOT Ubuntu or Debian. Exiting..."
    exit 1
fi

###########################################################################


# Install all .deb packages from offline-packages/
find ./offline-packages -type f -name '*.deb' | sort | xargs sudo dpkg -i || true

# Fix dependencies using only local .deb files (no internet)
sudo apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --no-download -f install -y

echo "All offline .deb packages installed."

# Install makeself offline
if ! command -v makeself.sh &> /dev/null; then
  if [ -f ./makeself/makeself.sh ]; then
    echo "Installing makeself.sh to /usr/local/bin (requires sudo)..."
    sudo cp ./makeself/makeself.sh /usr/local/bin/makeself.sh
    sudo chmod +x /usr/local/bin/makeself.sh
    echo "makeself.sh installed."
  else
    echo "makeself.sh not found in ./makeself/. Please provide it for offline install."
    exit 1
  fi
else
  echo "makeself.sh already installed."
fi

