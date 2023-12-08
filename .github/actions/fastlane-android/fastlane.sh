#!/usr/bin/env bash

# Set build number to GitHub run id
if [[ "${RUN_ID_AS_BUILD}" =~ ^(yes|1|true)$ ]]; then
  echo "FL_BUILD_NUMBER=${RUN_ID}" >> "${GITHUB_ENV}"
fi

# Unset optional variables that are empty
[[ -z "${FL_ENFORCED_BRANCH}" ]] && unset FL_ENFORCED_BRANCH
[[ -z "${FL_COMMIT_INCREMENT}" ]] && unset FL_COMMIT_INCREMENT
[[ -z "${FL_PUBLISH_BUILD}" ]] && unset FL_PUBLISH_BUILD
[[ -z "${FL_ANDROID_ARTIFACT}" ]] && unset FL_ANDROID_ARTIFACT
[[ -z "${FL_ANDROID_FLAVOR}" ]] && unset FL_ANDROID_FLAVOR
[[ -z "${FL_ANDROID_BUILD_TYPE}" ]] && unset FL_ANDROID_BUILD_TYPE
[[ -z "${FL_ANDROID_SKIP_SIGNING}" ]] && unset FL_ANDROID_SKIP_SIGNING

if [[ "${FL_PUBLISH_BUILD}" =~ ^(yes|1|true)$ ]] && [[ -z "${FL_GOOGLE_JSON_FILE}" ]]; then
  echo "::error ::Missing Google Credentials (publishing is enabled)"
  exit 1
else
  [[ -z "${FL_GOOGLE_JSON_FILE}" ]] && unset FL_GOOGLE_JSON_FILE
fi

if ! [[ "${FL_ANDROID_SKIP_SIGNING}" =~ ^(yes|1|true)$ ]] && [[ -z "${FL_ANDROID_STORE_FILE}" ]]; then
  echo "::error ::Missing Android Keystore (signing is enabled)"
  exit 1
else
  [[ -z "${FL_ANDROID_STORE_FILE}" ]] && unset FL_ANDROID_STORE_FILE
fi

if ! [[ "${FL_ANDROID_SKIP_SIGNING}" =~ ^(yes|1|true)$ ]] && [[ -z "${FL_ANDROID_STORE_PASSWORD}" ]]; then
  echo "::error ::Missing Android Keystore password (signing is enabled)"
  exit 1
else
  [[ -z "${FL_ANDROID_STORE_PASSWORD}" ]] && unset FL_ANDROID_STORE_PASSWORD
fi

if ! [[ "${FL_ANDROID_SKIP_SIGNING}" =~ ^(yes|1|true)$ ]] && [[ -z "${FL_ANDROID_KEY_ALIAS}" ]]; then
  echo "::error ::Missing Android Keystore key alias (signing is enabled)"
  exit 1
else
  [[ -z "${FL_ANDROID_KEY_ALIAS}" ]] && unset FL_ANDROID_KEY_ALIAS
fi

if ! [[ "${FL_ANDROID_SKIP_SIGNING}" =~ ^(yes|1|true)$ ]] && [[ -z "${FL_ANDROID_KEY_PASSWORD}" ]]; then
  echo "::error ::Missing Android Keystore key password (signing is enabled)"
  exit 1
else
  [[ -z "${FL_ANDROID_KEY_PASSWORD}" ]] && unset FL_ANDROID_KEY_PASSWORD
fi

# Execute fastlane using wrapper
./fastlanew android "${BUILD_LANE}"
