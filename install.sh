#!/usr/bin/env bash

readonly DESTINATION=$(realpath "${1:-$(pwd)}") # read first arg, default to current dir
readonly OS_NAME=$(uname)
readonly TMP_DIR="/tmp/ravn_mobile_ci_cd_installer_$(date +%s)" # use /tmp folder
readonly TMP_EXEC="${TMP_DIR}/installer"

readonly LIGHT_RED="\e[91m"
readonly LIGHT_GREEN="\e[92m"
readonly RESET_COLOR="\e[0m"

if [[ "${OS_NAME}" = "Darwin" ]]; then
  mkdir -p "${TMP_DIR}"
  echo -e "${LIGHT_GREEN}>${RESET_COLOR} Downloading installer for macOS..."
  curl -sL https://github.com/ravnhq/mobile-cicd-installer/releases/latest/download/installer-macos -o "${TMP_EXEC}" \
    && chmod +x "${TMP_EXEC}" \
    && bash -c "${TMP_EXEC} -d ${DESTINATION} -i"

elif [[ "${OS_NAME}" = "Linux" ]]; then
  echo -e "${LIGHT_GREEN}>${RESET_COLOR} Downloading installer for Linux..."
  mkdir -p "${TMP_DIR}"
  curl -sL https://github.com/ravnhq/mobile-cicd-installer/releases/latest/download/installer-linux -o "${TMP_EXEC}" \
    && chmod +x "${TMP_EXEC}" \
    && bash -c "${TMP_EXEC} -d ${DESTINATION} -i"
else
  echo -e "${LIGHT_RED}>${RESET_COLOR} Unknown operating system: ${OS_NAME}"
fi
