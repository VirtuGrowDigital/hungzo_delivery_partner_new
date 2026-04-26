# iOS App Store Readiness Guide

This project is close to iOS-ready, but you still need to finish Apple account and signing steps before uploading.

## What was fixed in the project

- iOS deployment target raised to `14.0` to satisfy `google_maps_flutter_ios`
- Missing iOS permission descriptions added for:
  - location
  - photo library access
  - photo library saving

## Items you still need to configure

1. Set a real iOS bundle identifier
   - Current value should be `com.mobilemeals.hungzoDeliveryPartnerApp`
   - In Xcode, open `ios/Runner.xcworkspace`
   - Select `Runner` project -> `Runner` target -> `Signing & Capabilities`
   - Change `Bundle Identifier` to something unique like `com.yourcompany.hungzodeliverypartner`

2. Confirm your Apple Developer team
   - The project currently has development team `YDZXLZNUAF`
   - If this is not your Apple Developer team, replace it in Xcode under `Signing & Capabilities`

3. Confirm app version before release
   - Flutter version is from `pubspec.yaml`: `1.0.0+6`
   - For App Store release, increase this before each new upload
   - Example:
     - `version: 1.0.1+7`

4. Verify app icons and launch assets
   - The project already contains an iOS `1024x1024` App Store icon
   - Recheck the icon in Xcode to make sure it matches your final branding

5. Check App Store policy-sensitive areas
   - If the app tracks drivers in the background, you may need extra background location setup and a stronger review explanation
   - If the app only tracks location while the app is open, the current permission wording is appropriate
   - If you use payments only outside iOS digital goods, your current setup is usually fine

## Build and upload flow

1. Open the iOS workspace
   - `open ios/Runner.xcworkspace`

2. In Xcode, set:
   - your Apple Developer account
   - the final bundle identifier
   - automatic signing
   - the correct version and build number

3. Connect App Store Connect
   - Go to [App Store Connect](https://appstoreconnect.apple.com/)
   - Create a new app if it does not exist yet
   - Use the same bundle identifier as in Xcode

4. Archive the app in Xcode
   - Select target device: `Any iOS Device (arm64)`
   - Menu: `Product` -> `Archive`

5. Upload from Organizer
   - After archive finishes, Xcode Organizer opens
   - Choose the archive
   - Click `Distribute App`
   - Choose `App Store Connect`
   - Choose `Upload`
   - Keep automatic symbol upload enabled unless you have a reason not to

6. Complete the App Store listing in App Store Connect
   - app name
   - subtitle
   - description
   - keywords
   - support URL
   - privacy policy URL
   - screenshots for required device sizes
   - app category
   - age rating

7. Fill the compliance forms
   - export compliance
   - content rights
   - privacy nutrition labels

8. Submit for review
   - After processing completes, add the build to your app version
   - Complete missing metadata
   - Click `Submit for Review`

## Commands to use locally

Install packages:

```bash
flutter pub get
```

Check Dart and Flutter issues:

```bash
flutter analyze
```

Build iOS without signing:

```bash
flutter build ios --release --no-codesign
```

## Important notes

- App Store upload requires macOS, Xcode, and an Apple Developer account
- `flutter build ipa` can also be used, but Xcode Organizer is usually the easiest path for a first App Store upload
- Do not submit with the default `com.example...` bundle ID
