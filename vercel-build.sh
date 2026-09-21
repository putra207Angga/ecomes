#!/bin/bash
set -e

echo "=== Starting E-Comes Abel'z Production Build for Vercel ==="

# 1. Install / Setup Flutter SDK (provides full Flutter & Dart SDK)
if [ ! -d "$HOME/flutter" ]; then
  echo ">>> Cloning Flutter SDK (stable channel)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$HOME/flutter/bin/cache/dart-sdk/bin:$HOME/.pub-cache/bin:$PATH"

echo ">>> Flutter version:"
flutter --version

echo ">>> Configuring Flutter Web..."
flutter config --enable-web --no-analytics

echo ">>> Activating Jaspr CLI..."
dart pub global activate jaspr_cli

echo ">>> Getting dependencies..."
dart pub get

echo ">>> Building Jaspr Web App..."
jaspr build -v

# 2. Prepare output directory for Vercel
echo ">>> Checking build output..."
if [ -d "build/jaspr/web" ] && [ -f "build/jaspr/web/index.html" ]; then
  echo ">>> Syncing files from build/jaspr/web to build/jaspr..."
  cp -r build/jaspr/web/* build/jaspr/ 2>/dev/null || true
fi

echo "=== Build finished successfully! ==="
ls -la build/jaspr
