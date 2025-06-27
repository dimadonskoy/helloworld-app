#!/usr/bin/env bash

#######################################################################     

#Developed by : Dmitri Donskoy
#Purpose : Install hello world app
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

TAR_PATH=./src/helloworld-app/helloworld-image.tar
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