#!/bin/bash
# @file install-zip.sh
# @brief Install zip and unzip.
#
# @description The script installs ``zip`` and ``unzip``.
#
# ==== Arguments
#
# The script does not accept any parameters.


echo "[INFO] Install and configure git"
sudo yum install -y zip unzip
echo "[DONE] Configured git with ssh keys"
