# Fastlane Android for GitHub Actions

# Inputs

Refer to the `inputs` section in the file [`action.yml`](action.yml) for a complete list of variables that can be set,
overall these variables overlap with the expected environment variables by the fastlane pipeline (with a few small
differences such as files expecting base64 contents).

To get the contents of a file in base64 you can run the following command:

```shell
cat path/to/your/file.json | base64 
```

And just copy the output, additionally, if you're on Mac you can append `pbcopy` to copy the output directly to your
clipboard:

```shell
cat path/to/your/file.json | base64 | pbcopy
```

#### Values

| Input                    | Description                                                                                        | Required | Default   |
|--------------------------|----------------------------------------------------------------------------------------------------|:--------:|-----------|
| `build-lane`             | The build lane that should be executed (values: beta, release)                                     |    ✓     |           |
| `enforced-branch`        | Branch to enforce, recommended (supports regex)                                                    |          |           |
| `run-id-as-build`        | Whether or not to use GitHub build id as build number                                              |          | `true`    |
| `commit-increment`       | Whether or not to commit and push version increment                                                |          | `false`   |
| `publish-build`          | Whether or not to publish build artifacts to the Play Store                                        |          | `true`    |
| `package-name`           | Android app package name (e.g. com.example.application)                                            |    ✓     |           |
| `google-json-key-base64` | Google Credentials JSON contents in base64 to upload artifacts (required if publishing is enabled) |    *     |           |
| `artifact`               | The type of the artifact that should be produced (values: apk, aab)                                |          | `aab`     |
| `flavor`                 | The build flavor that should be used                                                               |          |           |
| `build-type`             | The build type that should be used                                                                 |          | `Release` |
| `skip-signing`           | Whether or not to skip build signing (may not work if `build-type` is Release)                     |          | `false`   |
| `key-store-base64`       | Android Keystore data contents in base64 (required if signing is enabled)                          |    *     |           |
| `key-store-password`     | Android Keystore password (required if signing is enabled)                                         |    *     |           |
| `key-alias`              | Android Keystore key alias (required if signing is enabled)                                        |    *     |           |
| `key-password`           | Android Keystore key password (required if signing is enabled)                                     |    *     |           |

\* = _required based on other inputs_

# TODO

- [ ] Handle Android SDK installation if needed (based on an `android-home` variable)
- [ ] Handle JDK installation for building (based on version and `java-home`?)