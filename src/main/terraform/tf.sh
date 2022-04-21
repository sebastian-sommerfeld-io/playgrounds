#!/bin/bash
# @file tf.sh
# @brief Trigger terraform commands for this configuration.
#
# @description The script triggers terraform commands for this configuration.
#
# ==== Arguments
#
# The script does not accept any parameters.
#
# ===== See also
#
# * https://hub.docker.com/r/hashicorp/terraform
# * https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image
# * https://learn.hashicorp.com/tutorials/terraform/docker-build?in=terraform/docker-get-started


# @description Wrapper function to encapsulate the terraform docker container. The current working directory is mounted
# into the container and selected as working directory so that all file are available to terraform. Paths are preserved.
#
# @example
#    echo "test: $(tf -version)"
#
# @arg $@ String The terraform commands (1-n arguments) - $1 is mandatory
#
# @exitcode 1 If param is missing
function tf() {
  if [ -z "$1" ]; then
    echo -e "$LOG_ERROR No command passed to the terraform container"
    echo -e "$LOG_ERROR exit"
    exit 1
  fi

  echo -e "$LOG_INFO Run terraform container with command '$@'"
  docker run -it --rm \
    --volume "/var/run/docker.sock:/var/run/docker.sock" \
    --volume "$(pwd):$(pwd)" \
    --workdir "$(pwd)" \
    hashicorp/terraform:latest "$@"
}


# @description Print help.
#
# @example
#    echo "test: $(help)"
function help() {
  echo -e "$LOG_INFO Terraform wrapper for this configuration"
  echo -e "$LOG_INFO Available commands"
  echo -e "$LOG_INFO   start"
  echo -e "$LOG_INFO   stop"
  echo -e "$LOG_INFO   update"
  echo -e "$LOG_INFO   show"
  echo -e "$LOG_INFO   plan"
  echo -e "$LOG_INFO   validate"
  echo -e "$LOG_INFO   help"

  echo -e "$LOG_INFO Terraform version"
  tf -version

  echo -e "$LOG_INFO Terraform help"
  tf -help
}


# @description Startup this configuration by running ``terraform init`` and ``terraform apply``.
#
# @example
#    echo "test: $(start)"
function start() {
  echo -e "$LOG_INFO Startup this configuration"
  tf init
  tf apply -auto-approve
}


# @description Shutdown this configuration by running ``terraform destroy`` and cleanup.
#
# @example
#    echo "test: $(stop)"
function stop() {
  echo -e "$LOG_INFO Shutdown this configuration"
  tf destroy -auto-approve

  echo -e "$LOG_INFO Cleanup local filesystem"
  rm -rf .terraform*
  rm -rf *.tfstate*
}


# @description Update this configuration by running ``terraform apply``.
#
# @example
#    echo "test: $(update)"
function update() {
  echo -e "$LOG_INFO Update this configuration"
  tf apply -auto-approve
}


echo -e "$LOG_INFO Select action"
select choice in start stop update show plan validate help; do
  case "$choice" in
    start ) start; break;;
    stop ) stop; break;;
    update ) update; break;;
    plan ) tf plan; break;;
    show ) tf show; break;;
    validate ) tf validate; break;;
    help ) help; break;;
  esac
done
