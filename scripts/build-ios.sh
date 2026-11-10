#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "$(uname -s)" != Darwin ]] || ! command -v xcodebuild >/dev/null 2>&1; then
  echo 'This script requires a Mac with Xcode installed and selected.' >&2
  exit 1
fi
build_mode="${1:-simulator}"
vozi_build_dir="$PWD/build"
mkdir -p "$vozi_build_dir"
case "$build_mode" in
  simulator)
    xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Debug \
      -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
      -derivedDataPath "$vozi_build_dir/DerivedData" CODE_SIGNING_ALLOWED=NO build
    ditto -c -k --keepParent "$vozi_build_dir/DerivedData/Build/Products/Debug-iphonesimulator/App.app" "$vozi_build_dir/Vozi-Simulator.zip"
    echo "Simulator build: $vozi_build_dir/Vozi-Simulator.zip"
    ;;
  archive)
    : "${VOZI_APPLE_TEAM_ID:?Set VOZI_APPLE_TEAM_ID to your Apple Developer team ID first.}"
    xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Release \
      -destination 'generic/platform=iOS' -archivePath "$vozi_build_dir/Vozi.xcarchive" \
      DEVELOPMENT_TEAM="$VOZI_APPLE_TEAM_ID" CODE_SIGN_STYLE=Automatic \
      -allowProvisioningUpdates archive
    echo "Archive created: $vozi_build_dir/Vozi.xcarchive"
    echo 'Open the archive in Xcode Organizer and choose Distribute App to sign/export/upload.'
    ;;
  *) echo 'Usage: bash scripts/build-ios.sh [simulator|archive]' >&2; exit 2 ;;
esac
