#!/usr/bin/env bash

# Set build number to GitHub run id
if [[ "${RUN_ID_AS_BUILD}" =~ ^(yes|1|true)$ ]]; then
  echo "FL_BUILD_NUMBER=${RUN_ID}" >> "${GITHUB_ENV}"
fi

# Unset optional variables that are empty
[[ -z "${FL_ENFORCED_BRANCH}" ]] && unset FL_ENFORCED_BRANCH
[[ -z "${FL_COMMIT_INCREMENT}" ]] && unset FL_COMMIT_INCREMENT
[[ -z "${FL_PUBLISH_BUILD}" ]] && unset FL_PUBLISH_BUILD
[[ -z "${FL_TEAM_ID}" ]] && unset FL_TEAM_ID
[[ -z "${FL_ITC_TEAM_ID}" ]] && unset FL_ITC_TEAM_ID
[[ -z "${FL_IOS_CONFIGURATION}" ]] && unset FL_IOS_CONFIGURATION
[[ -z "${FL_XCODE_WORKSPACE}" ]] && unset FL_XCODE_WORKSPACE
[[ -z "${FL_APPLE_ENTERPRISE}" ]] && unset FL_APPLE_ENTERPRISE

# Execute fastlane using wrapper
./fastlanew ios "${BUILD_LANE}"
