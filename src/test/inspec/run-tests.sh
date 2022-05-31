#!/bin/bash
# @file run-tests.sh
# @brief Run Chef Inspec tests.
#
# @description The script runs Chef Inspec tests. Inspec runs inside a link:https://hub.docker.com/r/chef/inspec[Docker container (`chef/inspec`)].
#
# ==== Arguments
#
# The script does not accept any parameters.


SCRIPT_ARG_1="$1"
SCRIPT_ARG_2="$2"



# @description Wrapper function to encapsulate inspec in a docker container. The current working directory is mounted
# into the container and selected as working directory so that all file are available to inspec. Paths are preserved.
#
# @example
#    echo "test: $(inspec init <TEMPLATE>)"
#
# @arg $@ String The inspec commands (1-n arguments) - $1 is mandatory
#
# @exitcode 8 If param with inspec command is missing
function inspec() {
  if [ -z "$1" ]; then
    echo -e "$LOG_ERROR No command passed to the inspec container"
    echo -e "$LOG_ERROR exit" && exit 8
  fi

  docker run -it --rm \
    --volume "$(pwd):$(pwd)" \
    --workdir "$(pwd)" \
    chef/inspec:latest "$@"
}


# @description Create a new inspec test profile, re-organize some files and add files to git repo.
#
# @example
#    echo "test: $(initialize)"
#
# @arg $1 The global param $2 (passed to the whole script), contins the name of the new profile
#
# @exitcode 4 If profile already exists
# @exitcode 8 If param with profile name is missing
function initialize() {
  if [ -z "$1" ]; then
    echo -e "$LOG_ERROR No profile name passed"
    echo -e "$LOG_ERROR exit" && exit 8
  fi
  if [ -d "$1" ]; then
    echo -e "$LOG_ERROR Profile already exists"
    echo -e "$LOG_ERROR exit" && exit 4
  fi

  echo -e "$LOG_INFO Initialize profile $P$1$D"
  inspec init profile "$1" --chef-license=accept

  (
    cd "$1" || exit

    echo -e "$LOG_INFO Refactor README from markdown to asciidoc"
    sed 's/#/=/g' README.md > README.adoc
    adoc=$(sed '1 a Sebastian Sommerfeld <sebastian@sommerfeld.io>' README.adoc)
    echo "$adoc" > README.adoc
    adoc=$(sed 's/Example InSpec Profile/InSpec profile: cloud/g' README.adoc)
    echo "$adoc" > README.adoc
    rm README.md

    echo -e "$LOG_INFO Add valid document start to inspec.yml"
    yml=$(sed '1 i ---' inspec.yml)
    echo "$yml" > inspec.yml
    yml=$(sed 's/The Authors/Sebastian Sommerfeld/g' inspec.yml)
    echo "$yml" > inspec.yml
    yml=$(sed 's/you@example.com/sebastian@sommerfeld.io/g' inspec.yml)
    echo "$yml" > inspec.yml
  )

  (
    cd "../../../" || exit

    echo -e "$LOG_INFO Add profile to git repo"
    git add src/test/inspec*
  )
}


# @description Run all inspec test profiles
#
# @example
#    echo "test: $(run)"
function runTests() {
  echo -e "$LOG_INFO Running inspec tests ..."

    # todo ...
    # todo ...
    # todo ...
    # todo ...
    # todo ...
    # todo ...
}


if [ -z "$SCRIPT_ARG_1" ]; then
  runTests
elif [ "$SCRIPT_ARG_1" == "init" ]; then
  initialize "$SCRIPT_ARG_2"
else
  echo -e "$LOG_WARN Params have no effect"
  echo -e "$LOG_WARN Nothing to do"
  echo -e "$LOG_WARN Use one of these params"
  echo -e "$LOG_WARN  .. init <profile_name> .... Initialize new InSpec profile"
  echo -e "$LOG_WARN  .. <NO PARAMS> ............ Run all tests"
fi
