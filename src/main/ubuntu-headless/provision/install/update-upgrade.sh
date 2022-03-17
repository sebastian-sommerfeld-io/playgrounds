#!/bin/bash
# @file update-upgrade.sh
# @brief Update apt repository cache and upgrade packages.
#
# @description The script updates apt repository cache and upgrades packages.
#
# IMPORTANT: DON'T RUN THIS SCRIPT DIRECTLY - Script is invoked by Vagrant during link:https://www.vagrantup.com/docs/provisioning[provisioning].
#
# ==== Arguments
#
# The script does not accept any parameters.


echo "[INFO] Run update + upgrade"
sudo apt-get -y update
sudo apt-get -y upgrade

echo "[DONE] Finished update + upgrade"