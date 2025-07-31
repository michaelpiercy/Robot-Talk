#!/bin/bash

# Package Caleb's AI Assistant for distribution
echo "📦 Packaging Caleb's AI Assistant project..."

# Create project package
PROJECT_NAME="caleb-ai-assistant"
PACKAGE_NAME="${PROJECT_NAME}-$(date +%Y%m%d).zip"

# Create temporary directory
mkdir -p temp_package

# Copy essential files
echo "📁 Copying project files..."
cp -r main.lua temp_package/
cp -r config.lua temp_package/
cp -r build.settings temp_package/
cp -r Definitions/ temp_package/
cp -r Framework/ temp_package/
cp -r robot.png temp_package/
cp -r robot@2x.png temp_package/
cp -r robot@3x.png temp_package/
cp -r Icon.png temp_package/
cp -r README.md temp_package/
cp -r BUILD_GUIDE.md temp_package/

# Create package
echo "📦 Creating package: $PACKAGE_NAME"
cd temp_package
zip -r "../$PACKAGE_NAME" .
cd ..

# Clean up
rm -rf temp_package

echo "✅ Package created: $PACKAGE_NAME"
echo ""
echo "📋 Next steps:"
echo "1. Download Solar 2D SDK from https://solar2d.com/"
echo "2. Extract this package to a folder"
echo "3. Open Solar 2D Simulator"
echo "4. Load the project folder"
echo "5. Go to File → Build → Android"
echo "6. Follow the build wizard"
echo ""
echo "🌐 Or use Solar 2D Cloud Build:"
echo "1. Go to https://build.solar2d.com/"
echo "2. Upload the $PACKAGE_NAME file"
echo "3. Select Android platform"
echo "4. Download the generated APK"