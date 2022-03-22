#!/bin/bash
# @file git.sh
# @brief Install and configure git.
#
# @description The script installs and configures git.
#
# ==== Arguments
#
# The script does not accept any parameters.


echo "[INFO] Install and configure git"
sudo yum install -y git
git --version
git config --global user.name "sebastian"
git config --global user.email "sebastian@sommerfeld.io"
echo "[DONE] Configured git with ssh keys"
