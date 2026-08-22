# TechAllocate – GitHub APK build fix

This version is prepared for direct APK distribution through GitHub Releases.
It does not require Google Play Store publishing.

## Main changes
- Added Google Play Core 1.10.3 so R8 can resolve Flutter's optional deferred-component references.
- Kept release minification and resource shrinking.
- Kept `--split-per-abi` for smaller APKs.
- Removed broad Firebase / Google Play Services R8 keep rules.
- Removed `cupertino_icons` if it was unused.

## GitHub Actions build
Use:

    flutter build apk --release --split-per-abi

The recommended APK for modern Android phones is:

    build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

After pushing, check the GitHub Actions build.
