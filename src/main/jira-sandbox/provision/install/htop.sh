#!/bin/bash
# @file htop.sh
# @brief Install htop.
#
# @description The script installs htop.
#
# ==== Arguments
#
# The script does not accept any parameters.


echo "[INFO] Install and configure git"
sudo yum install -y htop
echo "[DONE] Configured git with ssh keys"
