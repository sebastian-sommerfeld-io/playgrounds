#!/bin/bash
# @file basic-packages
# @brief Install prerequisites and basic tools.
#
# @description The script installs packages as prerequisites for other installation steps. The installed packages
# allow ``apt`` to use a repository over HTTPS:
#
# * apt-transport-https
# * ca-certificates
# * gnupg-agent
# * software-properties-common
#
# Additionally the script installs basic software packages:
#
# * jq -> handle json in bash
# * ncdu
# * neofetch
# * yq -> handle yaml files in bash
#
# Lastly the script prints some information from packages shipped with the Box Image:
#
# * curl
# * git
# * htop
# * python3 / python3.9
#
# IMPORTANT: DON'T RUN THIS SCRIPT DIRECTLY - Script is invoked by Vagrant during link:https://www.vagrantup.com/docs/provisioning[provisioning].
#
# ==== Arguments
#
# The script does not accept any parameters.


echo "[INFO] Install prerequisites"
sudo apt-get install -y apt-transport-https
sudo apt-get install -y ca-certificates
sudo apt-get install -y gnupg-agent
sudo apt-get install -y software-properties-common
echo "[DONE] Installed prerequisites"

echo "[INFO] Install basic tools"
sudo apt-get install -y ncdu
sudo apt-get install -y neofetch
sudo apt-get install -y jq
snap install yq
echo "[DONE] Installed basic tools"

echo "[INFO] Print version information"
echo "[INFO]   curl = $(curl --version)"
echo "[INFO]   git = $(git version 2.32.0)"
echo "[INFO]   htop = $(htop --version)"
echo "[INFO]   python3 = $(python3 --version) / python3.9 = $(python3.9 --version)"
echo "[DONE] Printed version information"
