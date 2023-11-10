#!/usr/bin/env bash

script_path=$(realpath "$0")
script_dir=$(dirname "${script_path}")
destination=${1:-'..'} # read first arg, default to '..' (previous dir)

confirm() {
  read -rp "$1 (y/N): " yn

  yn=${yn,,}
  case "$yn" in
    y|yes)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
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
      if confirm ":: Directory fastlane.old/ already exists, remove it?"; then
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
  backup_existing_fastlane
  copy_recursively fastlane "${destination}/fastlane"
}

# Copy GitHub actions (with confirmation)
copy_github_actions() {
  android_action='.github/actions/fastlane-android'
  if confirm ":: Copy GitHub actions for Android (${android_action})?"; then
    [[ -d "${destination:?}/${android_action}" ]] && rm -rf "${destination:?}/${android_action}"
    mkdir -p "${destination:?}/.github/actions"
    cp -r "${android_action}" "${destination:?}/${android_action}"
  fi

  ios_action='.github/actions/fastlane-ios'
  if confirm ":: Copy GitHub actions for iOS (${ios_action})?"; then
    [[ -d "${destination:?}/${ios_action}" ]] && rm -rf "${destination:?}/${ios_action}"
    mkdir -p "${destination:?}/.github/actions"
    cp -r "${ios_action}" "${destination:?}/${ios_action}"
  fi
}

cd "${script_dir}" || exit

copy_ruby_files
confirm ":: Copy fastlane files?" && copy_fastlane
confirm ":: Copy GitHub actions?" && copy_github_actions

cd - &> /dev/null || echo ":: Couldn't go back to previous dir" || exit
echo ":: Finished! You can now remove this repository directory"
