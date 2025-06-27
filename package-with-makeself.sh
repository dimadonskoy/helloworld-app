#!/usr/bin/env bash

#######################################################################     

#Developed by : Dmitri Donskoy
#Purpose : Package all my project with makeself
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

ARCHIVE_NAME=hello-world-installer.run
PACKAGE_DIR=offline-package
MAKESELF=./makeself/makeself.sh


# Copy all project files except those in .gitignore
rsync -av --exclude='.git' --exclude='.gitignore' --exclude='*.run' --exclude='package-with-makeself.sh' --exclude='package/' --exclude='*.tar' --exclude='*.log' . $PACKAGE_DIR/

# Create self-extracting archive
bash "$MAKESELF" --notemp $PACKAGE_DIR $ARCHIVE_NAME "Hello World Offline Installer" bash

echo "Self-extracting installer created: $ARCHIVE_NAME" 