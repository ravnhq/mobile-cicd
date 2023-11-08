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

# Setup (copy files over)

Run the following commands to copy the configuration files contained in this repository into your own project:

```shell
cd <your-project-dir>
git clone git@github.com:ravnhq/mobile-cicd.git
chmod +x ./mobile-cicd/copy_files.sh # make it executable
./mobile-cicd/copy_files.sh
```

The script will copy the configuration files over the root directory of your project, checking if any of them already
exist and asking for your confirmation before replacing any of them. If a `fastlane` directory is already present, the
script will rename it to `fastlane.old`.

# Authentication

## Apple authentication

Authentication to Apple services is done using an App Store Connect API key, check the environment variables that need
to be set under the [.env.example](.env.example) and
follow [this link](https://docs.fastlane.tools/app-store-connect-api/) to learn how to create a key.

## Google authentication

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
   versionCode = property("version.code").toInt()
   ```
3. That's it, all your Android builds will use the value from the `gradle.properties` that's automatically updated by
   this pipeline.

# Frameworks

## Expo (or [adopted Prebuild](https://docs.expo.dev/guides/adopting-prebuild/))

> **Note:** Only app configurations written in JSON are supported at the moment (i.e. `app.json`)

#### iOS identifier and Android package name

> **Prerequisite:** Run `npx expo prebuild` to generate an initial `app.json` file or write one yourself.

Inside your `app.json` file make sure that the values for `expo.ios.bundleIdentifier` and `expo.android.package` are not
empty, and they match the values for the environment variables `FL_APP_IDENTIFIER` and `FL_PACKAGE_NAME` respectively.

#### Application versioning

> **Prerequisite:** Run `npx expo prebuild` to generate an initial `app.json` file or write one yourself.

Inside your `app.json` file write the initial values for `expo.android.versionCode`
and `expo.ios.buildNumber`, if not found by default starts with 1. Other versioning rules from environment variables
still apply (for example, `FL_BUILD_NUMBER=store` and `FL_COMMIT_INCREMENT=true`)

# Extending

As is, this pipeline process is simple, _build and publish_. If you need to add extra logic required by your project
you can do it in a variety of ways:

1. Modifying existing public lanes available in `fastlane/Fastfile` to add extra high-level steps, or adding new public
   lanes.
2. Modifying private lanes, note however that these usually contain more moving parts, if you're unsure on how or where
   to add your modifications contact one of the maintainers of this repository.
    - Common lanes are defined in the `fastlane/lanes/common.rb` file
    - iOS lanes are defined in the `fastlane/lanes/ios.rb` file
    - Android lanes are defined in the `fastlane/lanes/android.rb` file
3. Adding new private lanes (prefer to add them in the `fastlane/lanes` directory as the `fastlane/Fastfile` file should
   only contain public lanes)

# Running on CI

## GitHub Actions

- [fastlane-android](.github/actions/fastlane-android/README.md): Action to build and publish Android applications
- [fastlane-ios](.github/actions/fastlane-ios/README.md): Action to build and publish iOS applications

## CircleCI