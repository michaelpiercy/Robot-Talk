# 🚀 Build Guide - Caleb's AI Assistant APK

This guide will help you compile the AI assistant app into an Android APK file for testing on your device.

## Prerequisites

### 1. Install Solar 2D SDK
- Download Solar 2D SDK from: https://solar2d.com/
- Install it on your system
- Make sure the `corona` command is available in your PATH

### 2. Install Android SDK (if building locally)
- Download Android Studio: https://developer.android.com/studio
- Install Android SDK
- Set ANDROID_HOME environment variable

## Build Methods

### Method 1: Using Solar 2D Cloud Build (Recommended)

1. **Sign up for Solar 2D Cloud Build**
   - Go to: https://build.solar2d.com/
   - Create an account and log in

2. **Upload your project**
   - Zip your project folder
   - Upload to Solar 2D Cloud Build
   - Select Android as the target platform

3. **Download the APK**
   - Wait for the build to complete
   - Download the generated APK file

### Method 2: Local Build with Solar 2D SDK

1. **Open terminal/command prompt**
   ```bash
   cd /path/to/your/project
   ```

2. **Run the build script**
   ```bash
   ./build_android.sh
   ```

3. **Or build manually**
   ```bash
   corona build android --output build/
   ```

### Method 3: Using Solar 2D Simulator

1. **Open Solar 2D Simulator**
2. **Load your project**
3. **Go to File → Build → Android**
4. **Follow the build wizard**

## Installation on Android Device

### 1. Enable Unknown Sources
- Go to Settings → Security
- Enable "Unknown Sources" or "Install unknown apps"

### 2. Transfer APK
- Copy the APK file to your Android device
- You can use USB, email, or cloud storage

### 3. Install APK
- Navigate to the APK file on your device
- Tap the file to install
- Follow the installation prompts

## Troubleshooting

### Common Issues

1. **"Corona SDK not found"**
   - Make sure Solar 2D SDK is installed
   - Add corona to your system PATH

2. **"Build failed"**
   - Check that all required files are present
   - Verify build.settings configuration
   - Check for syntax errors in Lua files

3. **"APK won't install"**
   - Make sure "Unknown Sources" is enabled
   - Check that the APK is compatible with your Android version
   - Try uninstalling any previous version first

4. **"App crashes on startup"**
   - Check the device logs for error messages
   - Verify all required assets are included
   - Test in Solar 2D Simulator first

### Debug Mode

To build a debug version for testing:
```bash
corona build android --debug --output build/
```

## File Structure for Build

Make sure your project has these essential files:
```
├── main.lua              # Main entry point
├── config.lua            # App configuration
├── build.settings        # Build configuration
├── Icon.png             # App icon
├── Definitions/         # LLM modules
├── Framework/           # UI modules
└── robot.png           # Robot sprite
```

## Build Configuration

The `build.settings` file is configured for:
- **Android API 21+** (Android 5.0+)
- **Portrait orientation only**
- **Internet permissions** for future features
- **Touchscreen required**

## Testing the APK

1. **Install on device**
2. **Launch the app**
3. **Test features:**
   - Type messages in the input field
   - Check robot animations
   - Test personality switching
   - Verify memory management
   - Test conversation flow

## Performance Notes

- The app is optimized for modern Android devices
- Minimum RAM: 512MB
- Recommended: Android 6.0+ for best performance
- The LLM runs entirely on-device (no internet required)

## Next Steps

After successful installation:
1. Test all AI assistant features
2. Check robot animations work properly
3. Verify conversation memory functions
4. Test different personality modes
5. Report any issues for fixes

## Support

If you encounter build issues:
1. Check the Solar 2D documentation
2. Verify all dependencies are installed
3. Test with a simpler project first
4. Check the Solar 2D forums for help

---

**Happy testing! 🤖📱**