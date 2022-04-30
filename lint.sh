#!/bin/bash
# @file lint.sh
# @brief Update und run linters.
#
# @description The script updates linter definitions from ``assets`` Repo and runs linters.
#
# ==== Arguments
#
# The script does not accept any parameters.


echo -e "$LOG_INFO Download latest linter definitions"
linterDefinitions=(
  '.ls-lint.yml'
  '.yamllint'
  '.folderslintrc'
)
for file in "${linterDefinitions[@]}"; do
  rm "$file"
  curl -sL "https://raw.githubusercontent.com/sebastian-sommerfeld-io/infrastructure/main/resources/common-assets/linters/$file" -o "$file"
  git add "$file"
done

echo -e "$LOG_INFO ------------------------------------------------------------------------"
echo -e "$LOG_INFO Run linter containers"
echo -e "$LOG_INFO yamllint"
docker run -it --rm --volume "$(pwd):/data" --workdir "/data" cytopia/yamllint:latest .
echo -e "$LOG_INFO shellcheck"
docker run -it --rm --volume "$(pwd):/data" --workdir "/data" koalaman/shellcheck:latest ./*.sh

#echo -e "$LOG_INFO lint Dockerfile"
#(
#  cd src/main/workstations/kobol/vagrantboxes/pegasus/docker/images || exit
#
#  for dir in */ ; do
#    image=${dir%*/}
#    echo -e "$LOG_INFO Validate $image/Dockerfile"
#    docker run -i  --rm hadolint/hadolint < "$image/Dockerfile"
#  done
#)

echo -e "$LOG_INFO lslint"
docker run -it --rm --volume "$(pwd):/data" --workdir "/data" lslintorg/ls-lint:1.11.0
echo -e "$LOG_INFO folderslint"
docker run -i  --rm --volume "$(pwd):$(pwd)" --workdir "$(pwd)" pegasus/folderslint:latest folderslint .
echo -e "$LOG_INFO ------------------------------------------------------------------------"
