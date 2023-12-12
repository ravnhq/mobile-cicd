# RAVN Mobile CI/CD

#### Framework support:

- [x] Android
- [x] iOS
- [x] React Native
- [x] Flutter
- [x] Expo (based on React Native)

#### Deployment types:

- [x] Android Play Store
- [x] Android Play Store (Beta)
- [x] iOS TestFlight
- [x] iOS App Store

# Installation

Run the following command to install/update the configuration files into your project (run this command inside your
project root directory):

```shell
curl -s https://raw.githubusercontent.com/ravnhq/mobile-cicd/main/install.sh | sh
```

The script will copy the configuration files over the root directory of your project, checking if any of them already
exist and asking for your confirmation before replacing any of them. If a `fastlane` directory is already present, the
script will rename it to `fastlane.old`.

### Running locally

> **Prerequisite:** Install Ruby latest version on your system, preferably
> using [`rbenv`](https://github.com/rbenv/rbenv) to avoid messing up the default system installation.

> **Note:** Check other sections for configuration and then come back to this section to run locally.

To run locally use the provided wrapper `fastlanew`, for example:

```shell
./fastlanew android beta
```

#### Android

- `./fastlanew android beta`
- `./fastlanew android release`

#### iOS

- `./fastlanew ios beta`
- `./fastlanew ios release`

### Auto-updates

Configuration files in this repository may update from time to time to support new use cases and functionality, one way
to keep up-to-date is to let `fastlanew` check for updates automatically whenever any command is run or to check for
them explicitly with `./fastlanew self-update`.

# Authentication

#### Apple authentication

Authentication to Apple services is done using an App Store Connect API key, check the environment variables that need
to be set under the [.env.example](.env.example) and
follow [this link](https://docs.fastlane.tools/app-store-connect-api/) to learn how to create a key.

#### Google authentication

Follow [this link](https://docs.fastlane.tools/getting-started/android/setup/#setting-up-supply) on how to get JSON key
with Google Credentials to access Google APIs.

# Configuration

Configuration is managed using environment variables. You can find a list of these variables along with their
descriptions in the [.env.example](.env.example) file. With fastlane, you can use the `--env` flag to switch between
different environments by loading different dotenv
files ([see more here](https://docs.fastlane.tools/best-practices/keys/))

```shell
fastlane --env development # loads .env.development
fastlane --env release # loads .env.release
```

## Configure match

Run `fastlane match init` to set up match based on your organization and project needs. For more information on the
setup of match visit [this link](https://docs.fastlane.tools/actions/match/#setup).

## Configure version code in Android

Version code can be set automatically by this pipeline using the `version.code` property, to use it in your Android
project do the following:

1. Set the initial value in your `gradle.properties` file _(optional)_
   ```properties
   version.code=1
   ```
2. Read and use property in your `build.gradle` file:
   ```groovy
   versionCode property('version.code').toInteger()
   ```
   or with Gradle KTS (`build.gradle.kts`):
   ```kotlin
   versionCode = property("version.code").toString().toInt()
   ```
3. That's it, all your Android builds will use the value from the `gradle.properties` that's automatically updated by
   this pipeline.

# Frameworks

## Expo (or [adopted Prebuild](https://docs.expo.dev/guides/adopting-prebuild/))

> **Note:** Only app configurations written in JSON are supported at the moment (i.e. `app.json`)

#### iOS identifier and Android package name

> **Prerequisite:** Run `npx expo prebuild` to generate an initial `app.json` file or write one from scratch.

Inside your `app.json` file make sure that the values for `expo.ios.bundleIdentifier` and `expo.android.package` are not
empty, and they match the values for the environment variables `FL_APP_IDENTIFIER` and `FL_PACKAGE_NAME` respectively.

#### Application versioning

> **Prerequisite:** Run `npx expo prebuild` to generate an initial `app.json` file or write one from scratch.

Inside your `app.json` file write the initial values for `expo.android.versionCode`
and `expo.ios.buildNumber`, if not found by default starts with 1. Other versioning rules from environment variables
still apply (for example, `FL_BUILD_NUMBER=store` and `FL_COMMIT_INCREMENT=true`)

# Running on CI/CD services

### GitHub Actions

- [fastlane-android-action][fastlane-android-action]: Action to build and publish Android applications.
- [fastlane-ios-action][fastlane-ios-action]: Action to build and publish iOS applications.

[fastlane-android-action]: https://github.com/ravnhq/fastlane-android-action

[fastlane-ios-action]: https://github.com/ravnhq/fastlane-ios-action
