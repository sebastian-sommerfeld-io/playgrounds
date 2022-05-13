#!/bin/bash
# @file configure.sh
# @brief Provisioning script for Vagrantbox ``ubuntu-headless``.
#
# @description The scripts adds settings to the ``~/.bashrc`` file of the user "vagrant".
#
# * Write aliases to .bashrc file
# * Update bash prompt
#
# IMPORTANT: DON'T RUN THIS SCRIPT DIRECTLY - Script is invoked by Vagrant during link:https://www.vagrantup.com/docs/provisioning[provisioning].
#
# ==== Arguments
#
# The script does not accept any parameters.

export home="/home/vagrant"
bashrc="$home/.bashrc"

echo "[INFO]  ========== Variables ===================================================="
echo "[INFO]  HOME  ..................  $HOME"
echo "[INFO]  home variable  .........  $home"
echo "[INFO]  ========================================================================="

# Write aliases to .bashrc file
aliases=(
  "parse_git_branch() { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'; }"
  'alias ll="ls -alFh --color=auto"'
  'alias ls="ls -a --color=auto"'
  'alias grep="grep --color=auto"'
  'export LOG_DONE="[\e[32mDONE\e[0m]"'
  'export LOG_ERROR="[\e[1;31mERROR\e[0m]"'
  'export LOG_INFO="[\e[34mINFO\e[0m]"'
  'export LOG_WARN="[\e[93mWARN\e[0m]"'
  'export Y="\e[93m" # yellow'
  'export P="\e[35m" # pink'
  'export D="\e[0m"  # default (= white)'
)
for alias in "${aliases[@]}"; do
  grep -qxF "$alias" "$bashrc" || echo "$alias" >> "$bashrc"
done
echo "[DONE] Added aliases to $home/.bashrc (if not existing)"

# Update bash prompt
promptDefinition="\${debian_chroot:+(\$debian_chroot)}\[\033[01;35m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \033[01;35m\]\$(parse_git_branch)\[\033[00m\]\$ "
grep -qxF "export PS1='${promptDefinition}'" "$bashrc" || echo "export PS1='${promptDefinition}'" >>"$bashrc"
echo "[DONE] Changed prompt"
