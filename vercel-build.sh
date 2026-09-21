#!/bin/bash
set -e

echo "=== Starting E-Comes Abel'z Production Build for Vercel ==="

export CI=true
export FLUTTER_ROOT="$HOME/flutter"
export PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$HOME/.pub-cache/bin:$PATH"

git config --global --add safe.directory "*" 2>/dev/null || true

# 1. Install / Setup Flutter SDK
if [ ! -d "$FLUTTER_ROOT" ]; then
  echo ">>> Cloning Flutter SDK (stable channel)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_ROOT"
fi

echo ">>> Pre-caching Flutter Web engine & sky_engine..."
flutter precache --web

echo ">>> Configuring Flutter Web..."
flutter config --enable-web --no-analytics

echo ">>> Activating Jaspr CLI..."
flutter pub global activate jaspr_cli

echo ">>> Getting project dependencies..."
flutter pub get

echo ">>> Building Jaspr Web App..."
jaspr build -v

# 2. Prepare output directory for Vercel
echo ">>> Checking build output directory..."
if [ -d "build/jaspr/web" ] && [ -f "build/jaspr/web/index.html" ]; then
  echo ">>> Syncing files from build/jaspr/web to build/jaspr..."
  cp -r build/jaspr/web/* build/jaspr/ 2>/dev/null || true
fi

echo "=== Build finished successfully! ==="
ls -la build/jaspr
