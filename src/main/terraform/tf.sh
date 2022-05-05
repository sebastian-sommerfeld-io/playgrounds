#!/bin/bash
# @file tf.sh
# @brief Trigger terraform commands for this configuration.
#
# @description The script triggers terraform commands for a set of configurations.
#
# To apply a configuration for localhost, terraform must be able to start docker containers. Therefore the docker socket
# from the host is mounted into the container. This way the actual invocation of docker commands is delegated to the
# host.
#
# To apply a configuration for DigitalOcean, the docker container that runs terraform must be able to connect to the
# remote machines via SSH. Therefore the SSH information from the host are mounted into the container. This way the
# actual invocation of SSH commands is delegated to the host.
#
# ===== Prerequisites
#
# . The SSH keypair digitalocean_droplets.key / digitalocean_droplets.key.pub must exsist.
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


STAGE="n/a"
DIGITAL_OCEAN_DIR="digitalocean"

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
    echo -e "$LOG_ERROR $Y$STAGE$D No command passed to the terraform container"
    echo -e "$LOG_ERROR $Y$STAGE$D exit"
    exit 1
  fi

  (
    cd "$STAGE" || exit
    echo -e "$LOG_INFO $Y$STAGE$D Run terraform container"

    docker run -it --rm \
      --volume "/var/run/docker.sock:/var/run/docker.sock" \
      --volume "$SSH_AUTH_SOCK:$SSH_AUTH_SOCK" \
      --volume "$HOME/.ssh/digitalocean_droplets.key:/root/.ssh/digitalocean_droplets.key" \
      --volume "$(pwd):$(pwd)" \
      --workdir "$(pwd)" \
      hashicorp/terraform:latest "$@"
  )
}


# @description Startup this configuration by running ``terraform init`` and ``terraform apply``.
#
# @example
#    echo "test: $(start)"
function start() {
  echo -e "$LOG_INFO $Y$STAGE$D Startup this configuration"
  tf init

  if [ "$STAGE" = "$DIGITAL_OCEAN_DIR" ]; then
    token=$(cat "$DIGITAL_OCEAN_DIR/resources/.secrets/digitalocean.token")
    tf apply -auto-approve -var=do_token="$token"
  else
    tf apply -auto-approve
  fi
}


# @description Shutdown this configuration by running ``terraform destroy`` and cleanup.
#
# @example
#    echo "test: $(stop)"
function stop() {
  echo -e "$LOG_INFO $Y$STAGE$D Shutdown this configuration"
  if [ "$STAGE" = "$DIGITAL_OCEAN_DIR" ]; then
    token=$(cat "$DIGITAL_OCEAN_DIR/resources/.secrets/digitalocean.token")
    tf destroy -auto-approve -var=do_token="$token"
  else
    tf destroy -auto-approve
  fi

  (
    cd "$STAGE" || exit

    echo -e "$LOG_INFO $Y$STAGE$D Cleanup local filesystem"
    rm -rf .terraform*
    rm -rf -- *.tfstate*
  )
}


# @description Update this configuration by running ``terraform apply``.
#
# @example
#    echo "test: $(update)"
function update() {
  echo -e "$LOG_INFO $Y$STAGE$D Update this configuration"
  if [ "$STAGE" = "$DIGITAL_OCEAN_DIR" ]; then
    token=$(cat "$DIGITAL_OCEAN_DIR/resources/.secrets/digitalocean.token")
    tf apply -auto-approve -var=do_token="$token"
  else
    tf apply -auto-approve
  fi
}


# @description Update this configuration by running ``terraform apply``.
#
# @example
#    echo "test: $(plan)"
function plan() {
  echo -e "$LOG_INFO $Y$STAGE$D Plan this configuration"
  if [ "$STAGE" = "$DIGITAL_OCEAN_DIR" ]; then
    token=$(cat "$DIGITAL_OCEAN_DIR/resources/.secrets/digitalocean.token")
    tf plan -var=do_token="$token"
  else
    tf plan
  fi
}


echo -e "$LOG_INFO Select stage"
select dir in localhost "$DIGITAL_OCEAN_DIR"; do
  STAGE="$dir"
  echo -e "$LOG_INFO $Y$STAGE$D selected"
  break
done


echo -e "$LOG_INFO Select action"
select action in start stop update show plan validate; do
  case "$action" in
    start ) start;  break;;
    stop ) stop; break;;
    update ) update; break;;
    plan ) plan; break;;
    show ) tf show; break;;
    validate ) tf validate; break;;
  esac
done
