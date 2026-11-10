# Vozi v22 — Codemagic cloud build project

**No local Xcode is required for the recommended cloud workflow.** Start with `CLOUD-BUILD.md` and the root `codemagic.yaml`. Upload the extracted files to GitHub, import the repository into Codemagic, configure signing there, and run **Vozi App Store IPA - build only**.

USD, Bosnian convertible marks (BAM, displayed as KM), and euros are available in the currency menus. Fares, payment summaries, wallet examples, driver earnings, cancellation fees, and search results convert together. The choice is remembered on this device. Booked fares retain their quoted amount and currency in trip history.

Logout closes panels, stops the trip and driver-request timers, cancels pending demo verification, clears session data, and returns to sign-in. Currency preferences are retained. The desktop panels no longer intercept clicks while closed, and logout stays visible in the profile panel.

## Run on an iPhone or simulator

This ZIP contains a generated iOS source project, not a compiled .ipa or .xcarchive. Native compilation and signing have not run: the development environment is Linux and has no Xcode or Apple signing credentials.

1. Extract the ZIP on a Mac with a current Xcode supported by Capacitor 8.
2. Open `ios/App/App.xcodeproj`. Allow Xcode to resolve Swift packages. Capacitor 8.6.0 is pinned in the Swift package.
3. Select the App target and, for an actual iPhone, choose your development team under **Signing & Capabilities**. The proposed bundle identifier is `com.simpleai.vozi`; use an identifier owned by your Apple team before distribution.
4. Select an iPhone simulator or your connected iPhone and press Run.
5. To produce a signed distribution build, select **Any iOS Device**, choose **Product → Archive**, then **Distribute App** in Organizer. App Store/TestFlight distribution needs your Apple Developer membership and App Store Connect setup.

The iOS target supports iOS 15 and later. Web assets are bundled in the project, so native launch does not depend on a hosted Site sign-in page. Map tiles, street routing, and exchange-rate refresh still require internet access. No credentials or certificates are included.

Optional terminal builds on a Mac:

```bash
bash scripts/build-ios.sh simulator
# Device archive using your own Apple team:
VOZI_APPLE_TEAM_ID=YOUR_TEAM_ID bash scripts/build-ios.sh archive
```

The simulator command produces `build/Vozi-Simulator.zip`. It contains a simulator .app and cannot be installed on a physical iPhone. The archive command produces `build/Vozi.xcarchive` for signing/export in Xcode Organizer. These outputs are produced only when the scripts run successfully on a Mac; they are not included here.

## Change the app later

The editable web app is in `www/`. Serve that folder for a web deployment. To update the native bundle after edits, install Node 22 or newer, then run:

```bash
npm ci
npm run sync:ios
```

Dependencies are pinned in package-lock.json. Open the same Xcode project to build again.

## Rates and existing demo behavior

All base sample amounts are stored in BAM. The fixed BAM/EUR conversion is 1 EUR = 1.95583 BAM, as published by the Central Bank of Bosnia and Herzegovina. USD uses a dated Frankfurter reference rate and refreshes on launch; the included reference snapshot is dated 2026-11-06. If a refresh fails, the saved rate and date remain visible. Converted prices are estimates; this does not add card processing, multi-currency settlement, or a payment backend.

Login, verification, driver dispatch, wallet amounts, and car movement remain demo features. The live-GPS connection point from v19 is preserved. Real driver tracking between phones and account authentication still require a backend. The app is not an App Store submission or approval.

Reference documentation:
- https://capacitorjs.com/docs/ios
- https://capacitorjs.com/docs/ios/spm
- https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases
- https://www.cbbh.ba/CurrencyExchange/?lang=en
- https://frankfurter.dev/v1/

## Validation

Passed browser checks: currency selection and converted ride/driver prices; rider and driver logout; reopening the sign-in screen; currency preference after logout.

Passed DOM execution checks: all three currencies, repeated switching without fare drift, fixed quote currency in receipts, pickup/destination lifecycle, cancellation of pending trip/driver/verification callbacks, and protected navigation after logout. JavaScript syntax, native plist/configuration, matching bundled web assets, and build-script syntax were checked. Capacitor iOS generation and sync completed. Native compilation, signing, simulator launch, and device testing remain unverified until run on a Mac.
