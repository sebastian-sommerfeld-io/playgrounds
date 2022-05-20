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
CERT_NAME="playground-cert"

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
    echo -e "$LOG_ERROR [$P$STAGE$D] No command passed to the terraform container"
    echo -e "$LOG_ERROR [$P$STAGE$D] exit"
    exit 1
  fi

  (
    cd "$STAGE" || exit

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
  echo -e "$LOG_INFO [$P$STAGE$D] Startup this configuration"
  tf init

  if [ "$STAGE" = "$DIGITAL_OCEAN_DIR" ]; then
    validate

    token=$(cat "$DIGITAL_OCEAN_DIR/resources/.secrets/digitalocean.token")
    tf apply -auto-approve -var=do_token="$token"
  else
    validate

    tf apply -auto-approve
  fi

  graph
}


# @description Shutdown this configuration by running ``terraform destroy`` and cleanup.
#
# @example
#    echo "test: $(stop)"
function stop() {
  echo -e "$LOG_INFO [$P$STAGE$D] Shutdown this configuration"
  if [ "$STAGE" = "$DIGITAL_OCEAN_DIR" ]; then
    token=$(cat "$DIGITAL_OCEAN_DIR/resources/.secrets/digitalocean.token")

    echo -e "$LOG_INFO [$P$STAGE$D] Read all certificates with name and id from DigitalOcean using doctl"
    certs=$(docker run --rm -it --env=DIGITALOCEAN_ACCESS_TOKEN="$token" digitalocean/doctl:latest compute certificate list --format ID,Name --no-header)

    echo -e "$LOG_INFO [$P$STAGE$D] Iterate certs"
    while IFS= read -r line
    do
      if [[ "$line" == *"$CERT_NAME"* ]]; then
        id="${line:0:36}"
        echo -e "$LOG_INFO [$P$STAGE$D]     Found target cert '$CERT_NAME' ... delette cert using doctl"
        echo -e "$LOG_INFO [$P$STAGE$D]     Cert info = $line"
        echo -e "$LOG_INFO [$P$STAGE$D]       Cert ID = $id"
        docker run --rm -it --env=DIGITALOCEAN_ACCESS_TOKEN="$token" digitalocean/doctl:latest compute certificate delete --force "$id"
      fi
    done < <(printf '%s\n' "$certs")

    tf destroy -auto-approve -var=do_token="$token"
  else
    tf destroy -auto-approve
  fi

  (
    cd "$STAGE" || exit

    echo -e "$LOG_INFO [$P$STAGE$D] Cleanup local filesystem"
    rm -rf .terraform*
    rm -rf -- *.tfstate*
  )
}


# @description Update this configuration by running ``terraform apply``.
#
# @example
#    echo "test: $(update)"
function update() {
  echo -e "$LOG_INFO [$P$STAGE$D] Update this configuration"
  if [ "$STAGE" = "$DIGITAL_OCEAN_DIR" ]; then
    validate

    # todo ... delete cert in update too????? or make shure cert gets a random name ??? delete the cert via domain_name, not internal name

    token=$(cat "$DIGITAL_OCEAN_DIR/resources/.secrets/digitalocean.token")
    tf apply -auto-approve -var=do_token="$token"
  else
    validate

    tf apply -auto-approve
  fi

  graph
}


# @description Update this configuration by running ``terraform apply``.
#
# @example
#    echo "test: $(plan)"
function plan() {
  echo -e "$LOG_INFO [$P$STAGE$D] Plan this configuration"
  if [ "$STAGE" = "$DIGITAL_OCEAN_DIR" ]; then
    validate

    token=$(cat "$DIGITAL_OCEAN_DIR/resources/.secrets/digitalocean.token")
    tf plan -var=do_token="$token"
  else
    validate

    tf plan
  fi

  graph
}


# @description Validate this configuration by running ``terraform validate`` and apply consistent format to all .tf
# files by running ``terraform fmt -recursive``.
#
# @example
#    echo "test: $(validate)"
function validate() {
  echo -e "$LOG_INFO [$P$STAGE$D] Validate this configuration and apply consistent format to all .tf files"
  tf validate && tf fmt -recursive
}


# @description Generate diagram by running ``terraform graph`` and add this diagram to the documentation.
#
# @example
#    echo "test: $(graph)"
function graph() {
  echo -e "$LOG_INFO [$P$STAGE$D] Generate graph for this configuration"
  if [ "$STAGE" = "$DIGITAL_OCEAN_DIR" ]; then
    DIAGRAM_FILENAME="terraform-graph-$STAGE.png"

    echo -e "$LOG_INFO [$P$STAGE$D] Generate diagram specs"
    diagram=$(tf graph)

    echo -e "$LOG_INFO [$P$STAGE$D] Prettify diagram"
    PRETTY=$(echo "$diagram" | docker run -i --rm \
      --volume "$(pwd):$(pwd)" \
      --workdir "$(pwd)" \
      pegasus/tf-graph-beautifier:latest terraform-graph-beautifier --exclude="module.root.provider" --output-type=graphviz)

    echo -e "$LOG_INFO [$P$STAGE$D] Generate diagram image"
    echo "$PRETTY" | docker run -i --rm \
      --volume "$(pwd):$(pwd)" \
      --workdir "$(pwd)" \
      nshine/dot:latest > "$DIAGRAM_FILENAME"

    (
      cd ../../../ || exit

      ANTORA_DIR="docs/modules/ROOT/assets/images/terraform/generated"

      echo -e "$LOG_INFO [$P$STAGE$D] Move diagram to antora module"
      mv "src/main/terraform/$DIAGRAM_FILENAME" "$ANTORA_DIR/$DIAGRAM_FILENAME"

      echo -e "$LOG_INFO [$P$STAGE$D] Add diagram to git repo"
      git add "$ANTORA_DIR/$DIAGRAM_FILENAME"
    )

  else
    echo -e "$LOG_WARN No implementation for configurations other that $DIGITAL_OCEAN_DIR yet"
    echo -e "$LOG_WARN Graph creation skipped"
  fi
}


echo -e "$LOG_INFO Select stage"
select dir in localhost "$DIGITAL_OCEAN_DIR"; do
  STAGE="$dir"
  echo -e "$LOG_INFO [$P$STAGE$D] selected"
  break
done


echo -e "$LOG_INFO Select action"
select action in start stop update show plan validate graph init; do
  case "$action" in
    start ) start;  break;;
    stop ) stop; break;;
    update ) update; break;;
    plan ) plan; break;;
    show ) tf show; break;;
    validate ) validate; break;;
    graph ) graph; break;;
    init ) tf init; break;;
  esac
done
