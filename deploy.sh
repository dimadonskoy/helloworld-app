#!/usr/bin/env bash

#######################################################################     

#Developed by : Dmitri Donskoy
#Purpose : Install containerized app in offline env
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

function main(){
	set -x
		install_dependencies
		load_app
		makeself
}



function install_dependencies(){
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
}

##########################  Install app  #####################################

function load_app(){

      TAR_PATH=./src/helloworld-app/helloworld.tar
      DOCKERFILE_PATH=./src/helloworld-app/Dockerfile

      if [ -f "$TAR_PATH" ]; then
          echo "Found $TAR_PATH. Loading Docker image from tar..."
          docker load -i "$TAR_PATH"
          docker run -d -p 8090:8090 hello-world:local
      else
          if [ -f "$DOCKERFILE_PATH" ]; then
              echo "Tar file not found. Building Docker image from Dockerfile..."
              docker build -t hello-world:local -f "$DOCKERFILE_PATH" .
              docker run -d -p 8090:8090 hello-world:local
          else
              echo "Neither $TAR_PATH nor $DOCKERFILE_PATH found. Cannot proceed."
              exit 1
          fi
      fi
}

######################### Makeself #######################################

function makeself(){

      ARCHIVE_NAME=helloworld-installer.run
      PACKAGE_DIR=.
      MAKESELF=./makeself/makeself.sh


      # Copy all project files except those in .gitignore
      rsync -av --exclude='.*' --exclude='*/.*' --exclude='*.run' --exclude='package-with-makeself.sh' --exclude='package/' --exclude='*.tar' --exclude='*.log' ./ $PACKAGE_DIR/

      # Create self-extracting archive
      bash "$MAKESELF" --notemp $PACKAGE_DIR $ARCHIVE_NAME "Hello World Offline Installer" bash

      echo "Self-extracting installer created: $ARCHIVE_NAME" 
}

main