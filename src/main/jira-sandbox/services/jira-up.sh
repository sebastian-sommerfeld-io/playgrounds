#!/bin/bash
# @file jira-up.sh
# @brief Start Jira Instance from this Vagrantbox
#
# @description The scripts starts the Jira Software instance in Vagrantbox ``jira-sandbox``.
#
# ==== Arguments
#
# The script does not accept any parameters.


home="/home/vagrant"
JIRA_BASE_DIR="$home/jira"

echo "[INFO] Jira Start"

(
  cd "$JIRA_BASE_DIR/jira-installation/bin" || exit
  bash ./start-jira.sh
)

echo "[DONE] Jira Start complete"
