# RAVN Mobile CI/CD

#### Support for:

- [ ] Android 
- [x] iOS 
- [ ] React Native
- [ ] Flutter

#### Deployment types:

- [ ] Android Play Store
- [ ] Android Play Store (Beta)
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