#!/bin/bash
# @file jira-setup.sh
# @brief Install Jira in Vagrantbox jira-sandbox.
#
# @description The scripts installs Jira Software in Vagrantbox ``jira-sandbox``.
#
# NOTE: Script is invoked by Vagrant during link:https://www.vagrantup.com/docs/provisioning[provisioning] but can be
# run on its own as well (remove the existing Jira Instance first).
#
# ==== Arguments
#
# The script does not accept any parameters.


home="/home/vagrant"
TGZ_NAME="jira-software-8.17.0"
JIRA_BASE_DIR="$home/jira"

echo "[INFO] Jira Setup in $JIRA_BASE_DIR"

echo "[INFO] Check for existing jira installation"
if [ -d "$JIRA_BASE_DIR" ]; then
  echo "[ERROR] A jira installation is already present in $JIRA_BASE_DIR"
  echo "[ERROR] Exit" && exit
fi

echo "[INFO] Create jira base directory '$JIRA_BASE_DIR'"
mkdir -p "$JIRA_BASE_DIR"

(
  echo "[INFO] Change directory to jira base directory '$JIRA_BASE_DIR'"
  cd "$JIRA_BASE_DIR" || exit

  echo "[INFO] Download Jira Software archive from Atlassian website"
  curl -sL "https://product-downloads.atlassian.com/software/jira/downloads/atlassian-$TGZ_NAME.tar.gz" --output "$TGZ_NAME.tar.gz"

  echo "[INFO] Extract Archive"
  tar -xzf "$TGZ_NAME.tar.gz"

  echo "[INFO] Rename Jira folder to make sure jira-up.sh and jira-down.sh point to the correct location"
  mv "atlassian-$TGZ_NAME-standalone" jira-runtime

  echo "[INFO] Remove all windows files (*.bat) from jira-runtime/bin"
  rm jira-runtime/bin/*.bat

  echo "[INFO] Create jira home directory '$JIRA_BASE_DIR/jira-home'"
  mkdir -p "$JIRA_BASE_DIR/jira-home"

  propertiesFile="jira-runtime/atlassian-jira/WEB-INF/classes/jira-application.properties"
  echo "[INFO] Write Jira home directory to $propertiesFile"
  old="jira.home ="
  new="jira.home = $JIRA_BASE_DIR/jira-home"
  sed -i "s|$old|$new|g" "$propertiesFile"
)

echo "[DONE] Jira Setup complete"
