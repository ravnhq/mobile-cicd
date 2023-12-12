#!/usr/bin/env bash

script_dir=$(dirname "$(realpath "$0" 2> /dev/null)" || pwd)
destination=$(realpath "${1:-$(pwd)}") # read first arg, default to current dir
repo_dir="/tmp/ravn_mobile_ci_cd_$(date +%s)" # use /tmp folder

confirm() {
  local prompt="$1"
  local default=${2:-N}
  local values

  if [[ "${default}" = 'Y' ]]; then
    values='(Y/n)'
  else
    values='(y/N)'
  fi

  read -rp "${prompt} ${values}: " yn <&2

  yn=${yn:-$default}
  yn=$(echo "$yn" | awk '{print tolower($0)}')
  case "${yn}" in
    y|yes)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

question() {
  local prompt="$1"
  local values="$2"
  local default="$3"
  local regex

  while true; do
    read -rp "${prompt} (values: ${values})? [default: ${default}]: " answer <&2
      answer=${answer:-$default}

      regex="^($(echo "$values" | sed 's/, */|/g'))$"

      if [[ "${answer}" =~ ${regex} ]]; then
        echo "${answer}" && return 0
      else
        >&2 echo ":: Invalid input. Please choose one of the allowed values."
      fi
  done
}

copy_fastlane_wrapper() {
  cp "fastlanew" "${destination}/"
}

copy_file() {
  if [[ ! -f "${destination}/$1" ]] || confirm ":: File $1 already exists, do you want to replace it?" 'Y'; then
    cp "$1" "${destination}/"
  fi
}

clone_repository() {
  local version_url='https://raw.githubusercontent.com/ravnhq/mobile-cicd/main/.version'
  local remote_version

  remote_version=$(curl -s "${version_url}" | sed 's/[[:space:]]//g')

  echo ":: Downloading required files..."
  git clone --branch "${remote_version}" --depth 1 https://github.com/ravnhq/mobile-cicd "${repo_dir}" &> /dev/null

  if [[ $? -ne 0 ]]; then
    echo ":: Failed to clone repository..."
    exit 1
  fi
}

remove_repository() {
  [[ -d "${script_dir}/${repo_dir}" ]] && rm -rf "${script_dir:?}/${repo_dir}"
}

backup_existing_fastlane() {
  if [[ -d "${destination}/fastlane" ]]; then
    if ! confirm ":: Found an existing fastlane/ directory, do you want keep a backup?" 'Y'; then
      return
    fi

    echo ":: Copying existing fastlane/ directory to fastlane.old/"
    if [[ -d "${destination}/fastlane.old" ]]; then
      if confirm ":: Directory fastlane.old/ already exists, remove it?" 'Y'; then
        echo ":: Removing existing fastlane.old directory"
        rm -rf "${destination}/fastlane.old"
      else
        return
      fi
    fi

    cp -r "${destination}/fastlane" "${destination}/fastlane.old"
    echo ":: Note: Remove fastlane.old after consolidating your configuration files"
  fi
}

remove_region() {
    local start_marker="# region $1"
    local end_marker="# endregion $1"
    local file="$2"

    [[ ! -f "${file}" ]] && return 0

    perl -i -ne "print unless /${start_marker}/../${end_marker}/" "${file}"
}

remove_platform_code() {
   local platform="$1"
   local platform_to_remove

   case "${platform}" in
     android)
       platform_to_remove='ios'
       ;;
     ios)
       platform_to_remove='android'
       ;;
     *)
       return 0
       ;;
   esac

   local platform_lanes="${destination:?}/fastlane/lanes/${platform_to_remove}.rb"
   [[ -f "${platform_lanes}" ]] && rm "${platform_lanes}"

   remove_region "${platform_to_remove}" "${destination}/fastlane/Appfile"
   remove_region "${platform_to_remove}" "${destination}/fastlane/Fastfile"
   remove_region "${platform_to_remove}" "${destination}/.github/workflow.yml"
}

configure_cocoapods() {
  local platform="$1"

  if ! [[ "${platform}" =~ (ios|all) ]] || ! confirm ":: Does your iOS project use CocoaPods? (most multiplatform projects do)" 'Y'; then
    perl -i -ne "print unless /gem\s+'cocoapods'/" "${destination}/Gemfile"
  fi
}

copy_recursively() {
    local src_dir="$1"
    local dst_dir="$2"

    [[ -z "${src_dir}" || -z "${dst_dir}" ]] && return 1

    mkdir -p "${dst_dir}"

    find "${src_dir}" -type f | while read -r src_file; do
        local dst_file="${dst_dir}/${src_file#$src_dir/}"
        mkdir -p "$(dirname "${dst_file}")"
        cp "${src_file}" "${dst_file}"
    done
}

# Copy Ruby files required by fastlane
copy_ruby_files() {
  copy_file .ruby-version
  copy_file Gemfile
  copy_file Gemfile.lock
}

# Copy fastlane directory (backup any previous version)
copy_fastlane() {
  if ! confirm ":: Copy fastlane files?" 'Y'; then
    return 0
  fi

  backup_existing_fastlane
  copy_recursively fastlane "${destination}/fastlane"
}

# Configure platform code and configurations
configure_platforms() {
  remove_platform_code "$1"
  configure_cocoapods "$1"
}

exec_bundle_install() {
  echo ":: Installing required fastlane plugins..."
  bundle exec fastlane install_plugins > /dev/null
  bundle install > /dev/null
}

# Configure GitHub actions
configure_github_actions() {
  if ! confirm ":: Configure a basic GitHub Workflow?" 'Y'; then
    return 0
  fi

  if [[ -f "${destination}/.github/workflow.yml" ]] && ! confirm ":: Replace existing workflow.yml file? "; then
    return 0
  fi

  copy_file "github/workflow.yml" "${destination}/.github"
}

clone_repository
cd "${repo_dir}" || exit

platform=$(question ":: Platform to copy" "android, ios, all" "all")

copy_fastlane_wrapper
copy_ruby_files
copy_fastlane
configure_github_actions
configure_platforms "${platform}"
exec_bundle_install

cd - &> /dev/null || echo ":: Couldn't go back to previous dir" || exit
remove_repository || true
echo ":: Finished installation/update!"
