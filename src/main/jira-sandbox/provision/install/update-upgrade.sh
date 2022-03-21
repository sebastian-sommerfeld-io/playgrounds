#!/bin/bash
# @file update-upgrade.sh
# @brief Enable usage of the EPEL repository, update repository cache and upgrade packages.
#
# @description The script enables usage of the EPEL repository (Extra Packages for Enterprise Linux), updates the
# repository cache for yum and upgrades packages.
#
# IMPORTANT: DON'T RUN THIS SCRIPT DIRECTLY - Script is invoked by Vagrant during link:https://www.vagrantup.com/docs/provisioning[provisioning].
#
# ==== Arguments
#
# The script does not accept any parameters.


echo "[INFO] Run update + upgrade"
sudo yum update -y
echo "[DONE] Finished update + upgrade"
