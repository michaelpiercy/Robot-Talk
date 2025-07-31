#!/bin/bash

# Build script for Caleb's AI Assistant
# This script compiles the Solar 2D app into an Android APK

echo "🤖 Building Caleb's AI Assistant APK..."

# Check if Corona SDK is installed
if ! command -v corona &> /dev/null; then
    echo "❌ Corona SDK not found. Please install Solar 2D SDK first."
    echo "Download from: https://solar2d.com/"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build/
rm -f *.apk

# Create build directory
mkdir -p build

# Build for Android
echo "📱 Building Android APK..."
corona build android --output build/

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📦 APK file created in build/ directory"
    echo "📱 You can now install the APK on your Android device"
    echo ""
    echo "To install on your device:"
    echo "1. Enable 'Unknown Sources' in Android settings"
    echo "2. Transfer the APK file to your device"
    echo "3. Tap the APK file to install"
else
    echo "❌ Build failed. Please check the error messages above."
    exit 1
fi