#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="FolderToItunesApp"
BUILD_DIR="$REPO_DIR/.build/arm64-apple-macosx/release"
DIST_DIR="$REPO_DIR/dist"
APP_BUNDLE="$DIST_DIR/${APP_NAME}.app"

cd "$REPO_DIR"
swift build -c release --disable-sandbox

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
if [[ -d "$BUILD_DIR/FOLDER_TO_ITUNES_${APP_NAME}.bundle" ]]; then
  cp -R "$BUILD_DIR/FOLDER_TO_ITUNES_${APP_NAME}.bundle" "$APP_BUNDLE/Contents/Resources/"
fi

cat > "$APP_BUNDLE/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>es</string>
  <key>CFBundleExecutable</key>
  <string>FolderToItunesApp</string>
  <key>CFBundleIdentifier</key>
  <string>com.marquesedition.foldertoitunes</string>
  <key>CFBundleName</key>
  <string>FolderToItunes</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSAppleEventsUsageDescription</key>
  <string>Necesario para crear playlists y carpetas en Music.</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
EOF

echo "App creada en: $APP_BUNDLE"
