#!/usr/bin/env bash

script_path=$(realpath "$0")
script_dir=$(dirname "$script_path")
destination=${1:-'..'} # read first arg, default to '..' (previous dir)

confirm() {
  while true; do
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
  done
}

copy_file() {
  if [[ ! -f "${destination}/$1" ]] || confirm ":: File $1 already exists, do you want to replace it?"; then
    cp "$1" "${destination}/"
  fi
}

backup_existing_fastlane() {
  if [[ -d "${destination}/fastlane" ]]; then
    echo ":: Renaming existing fastlane/ directory to fastlane.old/"
    if [[ -d "${destination}/fastlane.old" ]]; then
      if confirm ":: Directory fastlane.old/ already exists, remove it?"; then
        echo ":: Removing existing fastlane.old directory"
        rm -rf "${destination}/fastlane.old"
      else
        return
      fi
    fi

    cp "${destination}/fastlane" "${destination}/fastlane.old"
    echo ":: Note: Remove fastlane.old after consolidating your configuration files"
  fi
}

# Copy Ruby files required by fastlane
copy_ruby_files() {
  copy_file .ruby-version
  copy_file Gemfile
  copy_file Gemfile.lock
}

backup_existing_fastlane
cp -r fastlane "${destination}/fastlane"
# Copy fastlane directory (backup any previous version)
copy_fastlane() {
  backup_existing_fastlane
  cp -r fastlane "${destination}/fastlane"
}

cd "$script_dir" || exit

copy_ruby_files
copy_fastlane

cd - &> /dev/null || echo ":: Couldn't go back to previous dir" || exit
echo ":: Finished! You can now remove this repository directory"