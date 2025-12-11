# Code Obfuscation Guide

## Огляд

Проект використовує code obfuscation для захисту коду в release збірках. Obfuscation робить код важчим для реверс-інжинірингу та зменшує розмір APK.

## Налаштування

### Android (ProGuard)
- ✅ Налаштовано в `android/app/build.gradle.kts`
- `isMinifyEnabled = true` - увімкнено мінімізацію коду
- `isShrinkResources = true` - видаляє невикористані ресурси
- ProGuard rules в `android/app/proguard-rules.pro`

### Flutter/Dart Obfuscation
- ✅ Автоматично виконується при використанні скриптів збірки
- ✅ Налаштовано в CI/CD (GitHub Actions)
- Debug symbols зберігаються окремо для можливості дебагу

## Використання

### Локальна збірка

#### Windows:
```bash
build_release.bat
```

#### Linux/Mac:
```bash
chmod +x build_release.sh
./build_release.sh
```

#### Вручну:
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### CI/CD
Obfuscation виконується автоматично в GitHub Actions при кожному build job.

## Debug Symbols

### Що це?
Debug symbols потрібні для дебагу obfuscated коду. Без них stack traces будуть нечитабельними.

### Де зберігаються?
- Локально: `build/app/outputs/symbols/`
- CI/CD: завантажуються як артефакт `debug-symbols` (зберігаються 90 днів)

### Як використовувати для дебагу?

1. **Отримати debug symbols:**
   - З локальної збірки: скопіювати з `build/app/outputs/symbols/`
   - З CI/CD: завантажити артефакт `debug-symbols` з GitHub Actions

2. **Деобфускація stack trace:**
   ```bash
   flutter symbolize -i <stack_trace_file> -d build/app/outputs/symbols/
   ```

3. **Або використати онлайн інструменти:**
   - Firebase Crashlytics автоматично використовує symbols для деобфускації
   - Sentry також підтримує Flutter symbols

## Важливо

⚠️ **Зберігайте debug symbols!**
- Без них неможливо дебажити obfuscated код
- Не комітьте symbols в git (вони в `.gitignore`)
- Зберігайте symbols окремо для кожної версії

## Перевірка obfuscation

Після збірки перевірте:
1. Розмір APK має бути меншим
2. В коді не має бути читабельних назв класів/методів
3. Debug symbols створені в `build/app/outputs/symbols/`

## Troubleshooting

### Проблема: Build fails з obfuscation
**Рішення:** Перевірте ProGuard rules в `proguard-rules.pro` - можливо потрібно додати правила для певних класів.

### Проблема: App crashes після obfuscation
**Рішення:** 
1. Перевірте ProGuard rules
2. Додайте `-keep` правила для класів, які використовуються через reflection
3. Перевірте логи з debug symbols

### Проблема: Debug symbols не створюються
**Рішення:** Переконайтеся, що використовуєте правильний шлях:
```bash
--split-debug-info=build/app/outputs/symbols
```

