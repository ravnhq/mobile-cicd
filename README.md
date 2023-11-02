# RAVN Mobile CI/CD

#### Framework support:

- [x] Android
- [x] iOS
- [x] React Native
- [x] Flutter
- [ ] Expo (based on React Native)

#### Deployment types:

- [x] Android Play Store
- [x] Android Play Store (Beta)
- [x] iOS TestFlight
- [x] iOS App Store

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
setup
of match visit [this link](https://docs.fastlane.tools/actions/match/#setup).

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

#### iOS identifier and Android package name

Run `npx expo prebuild` at least once to generate an initial `app.json` config for your project, inside that
configuration file make sure that the value for `expo.ios.bundleIdentifier` matches the value for the environment
variable `FL_APP_IDENTIFIER`, and that the value for `expo.android.package` matches the value for the environment
variable `FL_PACKAGE_NAME`.
