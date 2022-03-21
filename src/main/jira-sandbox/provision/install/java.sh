#!/bin/bash
# @file install-java.sh
# @brief Install OpenJDK 11.
#
# @description The script installs OpenJDK 11.
#
# ==== Arguments
#
# The script does not accept any parameters.


echo "[INFO] Install java"
sudo yum install -y java-11-openjdk.x86_64
echo "[DONE] Installed java"

echo "[INFO] Write JAVA_HOME information to .bashrc"
bashrc="/home/vagrant/.bashrc"
java_home="export JAVA_HOME=/usr/lib/jvm/jre"
jre_home="export JRE_HOME=/usr/lib/jvm/jre"
# shellcheck disable=SC2016
path='export PATH=$JAVA_HOME/bin:$PATH'
grep -qxF "$java_home" "$bashrc" || echo "$java_home" >> "$bashrc"
grep -qxF "$jre_home" "$bashrc" || echo "$jre_home" >> "$bashrc"
grep -qxF "$path" "$bashrc" || echo "$path" >> "$bashrc"
echo "[DONE] JAVA_HOME information written to .bashrc"
