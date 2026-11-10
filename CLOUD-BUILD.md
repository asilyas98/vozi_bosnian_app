# Build Vozi on Codemagic from Windows

Use the included `codemagic.yaml`. Codemagic supplies the Mac and Xcode; nothing here requires Xcode on your own computer.

## Put the source in GitHub

Extract this ZIP and upload the extracted files to a GitHub repository. `codemagic.yaml`, `package.json`, `package-lock.json`, `capacitor.config.json`, `ios/`, `www/`, and `scripts/` must be at the repository root. Do not upload just the ZIP or node_modules. The native files and web app are already included.

Use the App Store workflow for TestFlight and App Store distribution. The bundle ID is `com.simpleai.vozi`.

## Import and choose a build

1. In Codemagic, select **Add application**, connect GitHub, and select your Vozi repository. Use the YAML configuration.
2. Select your branch and let Codemagic scan the root `codemagic.yaml`.
3. Start one of these workflows after the applicable signing setup below:

| Workflow shown in Codemagic | Output | Where it runs |
| --- | --- | --- |
| Vozi iPhone IPA - registered devices | Signed ad-hoc `.ipa` | Only iPhones included in its provisioning profile |
| Vozi App Store IPA - build only | Signed App Store `.ipa` | Intended for later upload to App Store Connect / TestFlight; not direct installation |
| Vozi simulator - no Apple signing | `Vozi-Simulator.zip` containing `.app` | iOS simulator; not a physical iPhone |

The workflows run manually. There is no automatic App Store release, TestFlight upload, or email notification. After a successful build, download the artifact from the Codemagic build page. Files named `.ipa` in the configuration are expected outputs, not files already compiled in this ZIP.

## Signing for an actual iPhone

You need an Apple Developer Program membership for these signed cloud distribution workflows. In Codemagic Team settings, add your App Store Connect API key under **Team integrations → Developer Portal → Manage keys**. Enter the key and identifiers directly in Codemagic, not in source files.

Under **codemagic.yaml settings → Code signing identities**, generate an **Apple Distribution** certificate or upload an existing certificate and its private key. Codemagic can generate the certificate through its interface, so a local Mac is not required. If it offers a one-time download, retain it privately and upload it back to Code signing identities as its interface requires.

Create or fetch the matching provisioning profile for your Apple team and bundle ID. For the registered-devices workflow, use an **Ad Hoc** profile containing the UDIDs of the iPhones you intend to test. Add that profile to Codemagic Code signing identities. Then run **Vozi iPhone IPA - registered devices**. Downloading a signed IPA is not by itself an installation step; use an ad-hoc distribution service/install link that supports the registered devices.

For the App Store workflow, supply an **App Store** profile instead. A future TestFlight upload also needs an App Store Connect app record and publishing integration. That upload is deliberately not enabled by this configuration.

The proposed bundle ID is `com.simpleai.vozi`. Register it under your own Apple team, or change it consistently in all three locations before obtaining a profile:
- `capacitor.config.json` → `appId`
- `ios/App/App.xcodeproj/project.pbxproj` → both `PRODUCT_BUNDLE_IDENTIFIER` values
- Both signed workflows' `environment.ios_signing.bundle_identifier` in `codemagic.yaml`

No Apple membership/signing is needed for the simulator workflow, but that output will not install on your iPhone.

## What the build does

Each workflow installs the pinned Node dependencies, copies `www/` into the native app, checks the project inputs, and resolves the Capacitor Swift package through Xcode. Signed workflows select profiles already configured in Codemagic, give the app a build number based on Codemagic's project build counter, archive, and export an IPA. If you reuse an app record with higher existing build numbers, increase the offset in the two versioning steps before uploading to that record.

There is no CocoaPods step: this project uses Swift Package Manager. There is no `npm run build` step: `www/` is already a static web application.

## Verification status

The YAML structure, workflow shell syntax, native source references, pinned dependency inputs, shared Xcode scheme, and bundled JavaScript pass local checks. Cloud compilation and signing are not verified until Codemagic runs with the repository and signing identities.

Official references:
- https://docs.codemagic.io/yaml-quick-start/building-an-ionic-app/
- https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app/
- https://docs.codemagic.io/yaml-code-signing/signing-ios/
