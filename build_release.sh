#!/bin/bash
# Скрипт для збірки release версії з obfuscation

set -e  # Зупинити виконання при помилці

echo "=========================================="
echo "Building release APK with obfuscation..."
echo "=========================================="

# Перевірка наявності Flutter
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter не знайдено. Переконайтеся, що Flutter встановлено та додано до PATH."
    exit 1
fi

# Отримуємо залежності
echo "Getting dependencies..."
flutter pub get

# Очищаємо попередні збірки
echo "Cleaning previous builds..."
flutter clean

# Збірка з obfuscation та split debug info
echo "Building APK with obfuscation..."
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ Release APK built successfully!"
    echo "=========================================="
    echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo "Debug symbols: build/app/outputs/symbols"
    echo ""
    echo "⚠️  Важливо: Збережіть debug symbols для можливості дебагу!"
    echo "=========================================="
else
    echo ""
    echo "=========================================="
    echo "❌ Build failed!"
    echo "=========================================="
    exit 1
fi

