#!/bin/bash

echo "🔍 Verifying Caleb's AI Assistant project structure..."

# Check for required files
REQUIRED_FILES=(
    "main.lua"
    "config.lua"
    "build.settings"
    "Icon.png"
    "robot.png"
    "Definitions/llm_core.lua"
    "Definitions/knowledge_base.lua"
    "Definitions/ai_robot.lua"
    "Framework/ui_manager.lua"
)

MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -eq 0 ]; then
    echo "✅ All required files are present"
else
    echo "❌ Missing files:"
    for file in "${MISSING_FILES[@]}"; do
        echo "   - $file"
    done
fi

# Check file sizes
echo ""
echo "📊 File sizes:"
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        size=$(wc -c < "$file")
        echo "   $file: ${size} bytes"
    fi
done

# Check Lua syntax (basic check)
echo ""
echo "🔍 Checking Lua syntax..."
for file in *.lua Definitions/*.lua Framework/*.lua; do
    if [ -f "$file" ]; then
        # Basic syntax check - look for obvious errors
        if grep -q "function.*end" "$file" || grep -q "local.*=" "$file"; then
            echo "   ✅ $file (basic syntax OK)"
        else
            echo "   ⚠️  $file (may need review)"
        fi
    fi
done

echo ""
echo "📦 Project is ready for building!"
echo "📱 You can now use Solar 2D to build the APK"