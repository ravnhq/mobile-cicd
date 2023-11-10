#!/usr/bin/env bash

script_path=$(realpath "$0")
script_dir=$(dirname "${script_path}")
destination=${1:-'..'} # read first arg, default to '..' (previous dir)

confirm() {
  local prompt="$1"
  local default=${2:-N}
  local values

  if [[ "${default}" = 'Y' ]]; then
    values='(Y/n)'
  else
    values='(y/N)'
  fi

  read -rp "${prompt} ${values}: " yn

  yn=${yn:-$default}
  case "${yn,,}" in
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
    read -rp "${prompt} (values: ${values})? [default: ${default}]: " answer
      answer=${answer:-$default}

      regex="^($(echo "$values" | sed 's/, */|/g'))$"

      if [[ "${answer}" =~ ${regex} ]]; then
        echo "${answer}" && return 0
      else
        >&2 echo ":: Invalid input. Please choose one of the allowed values."
      fi
  done
}

copy_file() {
  if [[ ! -f "${destination}/$1" ]] || confirm ":: File $1 already exists, do you want to replace it?"; then
    cp "$1" "${destination}/"
  fi
}

backup_existing_fastlane() {
  if [[ -d "${destination}/fastlane" ]]; then
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

   rm "${destination:?}/fastlane/lanes/${platform_to_remove}.rb"
   remove_region "${platform_to_remove}" "${destination}/fastlane/Appfile"
   remove_region "${platform_to_remove}" "${destination}/fastlane/Fastfile"
}

configure_cocoapods() {
  local platform="$1"

  if ! [[ "${platform}" =~ (ios|all) ]]; then
    return
  fi

  if ! confirm ":: Does your iOS project use CocoaPods? (most multiplatform projects do)"; then
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
  local platform="$1"

  backup_existing_fastlane
  copy_recursively fastlane "${destination}/fastlane"
}

# Configure platform code and configurations
configure_platforms() {
  remove_platform_code "$1"
  configure_cocoapods "$1"
}

exec_bundle_install() {
  bundle install
}

# Copy GitHub actions (with confirmation)
copy_github_actions() {
  local platform="$1"

  android_action='.github/actions/fastlane-android'
  if [[ "${platform}" =~ (android|all) ]] && confirm ":: Copy GitHub actions for Android (${android_action})?" 'Y'; then
    [[ -d "${destination:?}/${android_action}" ]] && rm -rf "${destination:?}/${android_action}"
    mkdir -p "${destination:?}/.github/actions"
    cp -r "${android_action}" "${destination:?}/${android_action}"
  fi

  ios_action='.github/actions/fastlane-ios'
  if [[ "${platform}" =~ (ios|all) ]] && confirm ":: Copy GitHub actions for iOS (${ios_action})?" 'Y'; then
    [[ -d "${destination:?}/${ios_action}" ]] && rm -rf "${destination:?}/${ios_action}"
    mkdir -p "${destination:?}/.github/actions"
    cp -r "${ios_action}" "${destination:?}/${ios_action}"
  fi
}

cd "${script_dir}" || exit

platform=$(question ":: Platform to copy" "android, ios, all" "all")

copy_ruby_files
confirm ":: Copy fastlane files?" 'Y' && copy_fastlane "${platform}"
configure_platforms "${platform}"
copy_github_actions "${platform}"
confirm ":: Execute 'bundle install' to install gems?" 'Y' && exec_bundle_install

cd - &> /dev/null || echo ":: Couldn't go back to previous dir" || exit
echo ":: Finished! You can now remove this repository directory"
