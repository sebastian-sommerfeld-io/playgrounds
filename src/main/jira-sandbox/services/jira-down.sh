#!/bin/bash
# @file jira-down.sh
# @brief Stop Jira Instance from this Vagrantbox
#
# @description The scripts stops the Jira Software instance in Vagrantbox ``jira-sandbox``.
#
# ==== Arguments
#
# The script does not accept any parameters.


home="/home/vagrant"
JIRA_BASE_DIR="$home/jira"

echo "[INFO] Jira Stop"

(
  cd "$JIRA_BASE_DIR/jira-runtime/bin" || exit
  bash ./stop-jira.sh
)

echo "[DONE] Jira Stop complete"
