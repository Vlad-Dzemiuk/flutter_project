@echo off
REM Скрипт для збірки release версії з obfuscation (Windows)

setlocal enabledelayedexpansion

echo ==========================================
echo Building release APK with obfuscation...
echo ==========================================

REM Перевірка наявності Flutter
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Flutter не знайдено. Переконайтеся, що Flutter встановлено та додано до PATH.
    exit /b 1
)

REM Отримуємо залежності
echo Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo Error: Failed to get dependencies
    exit /b 1
)

REM Очищаємо попередні збірки
echo Cleaning previous builds...
call flutter clean

REM Збірка з obfuscation та split debug info
echo Building APK with obfuscation...
call flutter build apk --release --obfuscate --split-debug-info=build\app\outputs\symbols

if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo ✅ Release APK built successfully!
    echo ==========================================
    echo APK location: build\app\outputs\flutter-apk\app-release.apk
    echo Debug symbols: build\app\outputs\symbols
    echo.
    echo ⚠️  Важливо: Збережіть debug symbols для можливості дебагу!
    echo ==========================================
) else (
    echo.
    echo ==========================================
    echo ❌ Build failed!
    echo ==========================================
    exit /b 1
)

