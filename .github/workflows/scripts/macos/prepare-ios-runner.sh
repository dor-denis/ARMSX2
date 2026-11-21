#!/usr/bin/env bash
set -euo pipefail

# The xcode-27 image supplies an Apple Silicon host and the Xcode 27 default.
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
xcodebuild -version
xcodebuild -showsdks

XCODE_VERSION="$(xcodebuild -version | awk '/^Xcode / {print $2}')"
SDK_VERSION="$(xcrun --sdk iphoneos --show-sdk-version)"
if [[ "$(uname -m)" != arm64 || "$XCODE_VERSION" != 27.* || "$SDK_VERSION" != 27.* ]]; then
  echo "::error::Expected Apple Silicon, Xcode 27.x and iPhoneOS SDK 27.x; got $(uname -m), Xcode $XCODE_VERSION, SDK $SDK_VERSION."
  exit 1
fi

# Metal is a separately downloadable component on recent Xcode versions.
for attempt in 1 2 3; do
  if xcrun --sdk iphoneos metal -v && xcrun --sdk iphoneos --find metallib; then
    exit 0
  fi
  echo "Installing Metal toolchain (attempt $attempt/3)..."
  xcodebuild -downloadComponent MetalToolchain || true
done
xcrun --sdk iphoneos metal -v
xcrun --sdk iphoneos --find metallib
