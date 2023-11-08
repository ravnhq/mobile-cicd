# Fastlane iOS for GitHub Actions

# Xcode SDKs

GitHub macOS runners already have SDKs (and other utilities) installed for iOS (see [here][xcode-sdks]). If the runner
you're using does not come with this support out of the box it must be manually configured before running this action.

[xcode-sdks]: https://github.com/actions/runner-images/blob/main/images/macos/macos-13-Readme.md#xcode

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

#### Variables

| Input              | Description                                                                | Required | Default   |
|--------------------|----------------------------------------------------------------------------|:--------:|-----------|
| `build-lane`       | The build lane that should be executed (values: beta, release)             |    ✓     |           |
| `enforced-branch`  | Branch to enforce, recommended (supports regex)                            |          |           |
| `run-id-as-build`  | Whether or not to use GitHub build id as build number                      |          | `true`    |
| `commit-increment` | Whether or not to commit and push version increment                        |          | `false`   |
| `publish-build`    | Whether or not to publish build artifacts to the App Store (or TestFlight) |          | `true`    |
| `app-identifier`   | App Store application bundle identifier                                    |    ✓     |           |
| `team-id`          | App Store Connect Team ID (if any)                                         |          |           |
| `itc-team-id`      | iTunes Connect Team ID (if any)                                            |          |           |
| `scheme`           | iOS project scheme to build                                                |          | `Release` |
| `xcodeproj`        | Path to main XCode project (required if not found automatically)           |    *     |           |
| `xcworkspace`      | Path to main XCode workspace                                               |          |           |
| `apple-key-id`     | Apple App Store Connect Key ID                                             |    ✓     |           |
| `apple-issuer-id`  | Apple App Store Connect Issuer ID                                          |    ✓     |           |
| `apple-key-base64` | Apple App Store Connect Key contents (.p8) in base64                       |    ✓     |           |
| `enterprise`       | Whether or not it is Apple Enterprise                                      |          | `false`   |
| `match-password`   | Password to encrypt/decrypt certificates using match                       |    ✓     |           |
