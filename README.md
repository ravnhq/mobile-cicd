# RAVN Mobile CI/CD

#### Support for:

- [x] Android 
- [x] iOS 
- [x] React Native
- [x] Flutter

#### Deployment types:

- [x] Android Play Store
- [x] Android Play Store (Beta)
- [x] iOS TestFlight
- [x] iOS App Store

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

Run `fastlane match init` to set up match based on your organization and project needs. For more information on the setup
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