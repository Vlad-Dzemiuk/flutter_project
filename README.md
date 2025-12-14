# 🎬 Movie Discovery App

Flutter додаток для пошуку та перегляду інформації про фільми та серіали з використанням The Movie Database (TMDB) API.

## 🎯 Обрана тема

**Movie Discovery App** - додаток для каталогу фільмів і серіалів з пошуком, фільтрацією та збереженням улюблених.

## 🏗️ Архітектура

Проект реалізований з використанням **Clean Architecture** з трьома шарами:

### Presentation Layer
- **BLoC/Cubit** для state management
- UI компоненти (Pages, Widgets)
- State класи

### Domain Layer
- **Use Cases** для бізнес-логіки:
  - `GetPopularContentUseCase` - завантаження популярного контенту
  - `SearchMediaUseCase` - пошук медіа
  - `SignInUseCase` - авторизація користувача
  - `RegisterUseCase` - реєстрація користувача
  - `UpdateProfileUseCase` - оновлення профілю
- Domain entities

### Data Layer
- **Repository Pattern** для всіх API calls
- Data sources (API services, local databases)
- Data models

### Dependency Injection
- **GetIt** для dependency injection
- Централізована реєстрація в `lib/core/di.dart`

## 🌐 API Integration

### Використовувані API:
- **[The Movie Database (TMDB) API](https://www.themoviedb.org/documentation/api)** - основне джерело даних про фільми та серіали

### Особливості інтеграції:
- **HTTP client**: `http` package для API запитів
- **Error handling**: обробка помилок мережі з user-friendly повідомленнями
- **Offline-first**: кешування даних в Drift базі даних через `LocalCacheDb`
- **Interceptors**: логування та обробка помилок
- **Secure Storage**: збереження API ключів в `flutter_secure_storage`

## 🚀 Features

### Основні функції:
- ✅ **Каталог фільмів і серіалів** - перегляд популярного контенту
- ✅ **Пошук** - пошук за назвою, жанром, роком, рейтингом
- ✅ **Деталі медіа** - детальна інформація про фільми/серіали з трейлерами та відгуками
- ✅ **Favorites/Watchlist** - збереження улюблених фільмів
- ✅ **Collections** - створення колекцій медіа
- ✅ **Профіль користувача** - управління профілем та налаштуваннями
- ✅ **Авторизація** - реєстрація та вхід користувачів

### Authentication Flow:
- Локальна авторизація через Drift базу даних
- Збереження сесії користувача
- Захищені маршрути

## 📁 Структура проекту

```
project/
├── lib/
│   ├── core/              # Utils, constants, DI, domain base classes
│   │   ├── domain/        # Base use case classes
│   │   ├── network/       # Network configuration
│   │   ├── storage/        # Local storage (Drift, Secure Storage)
│   │   └── ...
│   ├── features/          # Feature modules
│   │   ├── auth/          # Authentication
│   │   │   ├── domain/
│   │   │   │   └── usecases/  # SignInUseCase, RegisterUseCase
│   │   │   └── ...
│   │   ├── home/          # Home screen with media catalog
│   │   │   ├── domain/
│   │   │   │   └── usecases/  # GetPopularContentUseCase, SearchMediaUseCase
│   │   │   └── ...
│   │   ├── favorites/     # Favorites feature
│   │   ├── profile/       # User profile
│   │   │   ├── domain/
│   │   │   │   └── usecases/  # UpdateProfileUseCase
│   │   │   └── ...
│   │   ├── collections/  # Media collections
│   │   └── search/        # Search feature
│   ├── shared/           # Shared widgets/models
│   │   └── widgets/
│   └── main.dart
├── test/                 # Unit + Widget tests
├── integration_test/     # E2E tests
├── .github/workflows/    # CI/CD
│   └── flutter.yml
├── README.md            # Детальний опис
└── pubspec.yaml
```

## 🧪 Testing

### Поточний стан:
- ✅ **Unit tests**: тести для BLoC, use cases, repositories, entities
- ✅ **Widget tests**: тести для всіх UI компонентів
- ✅ **Integration tests**: E2E тести для всіх user flows

### Запуск тестів:
```bash
# Всі тести
flutter test

# Тільки widget тести
flutter test test/widget/

# Тільки integration тести
flutter test integration_test/
```

Детальні інструкції див. в [TESTING_GUIDE.md](TESTING_GUIDE.md)

## 🛠️ Setup Instructions

### Передумови:
- Flutter SDK (3.24.0 або новіша версія)
- Dart SDK
- Android Studio / VS Code з Flutter extensions

### Кроки встановлення:

1. **Клонувати репозиторій**
   ```bash
   git clone <repository-url>
   cd project
   ```

2. **Налаштувати API ключі**
   - Скопіювати файл `.env.example` як `.env`:
     ```bash
     cp .env.example .env
     ```
   - Відкрити `.env` та заповнити значення:
     ```
     TMDB_API_KEY=your_api_key_here
     AUTH_METHOD=local
     ```
   - Отримати TMDB API key: https://www.themoviedb.org/settings/api

3. **Встановити залежності**
   ```bash
   flutter pub get
   ```

4. **Запустити додаток**
   ```bash
   flutter run
   ```

### Для Android:
```bash
flutter run -d android
```

### Для release збірки з obfuscation:
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

**Важливо:**
- Debug symbols зберігаються в `build/app/outputs/symbols/` - збережіть їх для можливості дебагу!
- Obfuscation робить код важчим для реверс-інжинірингу та зменшує розмір APK
- У CI/CD obfuscation виконується автоматично
- Детальна інструкція: див. [OBFUSCATION.md](OBFUSCATION.md)

### Для запуску тестів:
```bash
flutter test
```

## 🔧 CI/CD

Проект використовує **GitHub Actions** для автоматизації:

### Workflow файл: `.github/workflows/flutter.yml`

**Після кожного push/PR виконується:**

1. **Test Job:**
   - Створення `.env` файлу з environment variables
   - Перевірка форматування коду
   - Аналіз коду (`flutter analyze`)
   - Запуск тестів з покриттям

2. **Build Job:**
   - Створення `.env` файлу з environment variables
   - Збірка release APK з obfuscation
   - Завантаження артефакту APK
   - Завантаження debug symbols для можливості дебагу

### Налаштування GitHub Secrets

Для роботи CI/CD потрібно налаштувати GitHub Secrets:

1. Перейти в **Settings** → **Secrets and variables** → **Actions**
2. Додати наступні secrets:
   - `TMDB_API_KEY` - ваш TMDB API ключ

**Як додати secret:**
- Натиснути **New repository secret**
- Name: `TMDB_API_KEY`
- Secret: ваш API ключ з TMDB
- Натиснути **Add secret**

### Перевірка CI/CD:
- Перейти до вкладки "Actions" в GitHub репозиторії
- Переглянути статус останніх запусків
- Завантажити зібраний APK з артефактів

## 📊 Performance Optimizations

### Реалізовані оптимізації:
- ✅ **Lazy loading** для списків медіа
- ✅ **Image caching** через `cached_network_image`
- ✅ **Widget rebuild optimization** через правильне використання BLoC
- ✅ **Memory management** - правильне dispose ресурсів
- ✅ **Local caching** - кешування API відповідей в Drift базі даних
- ✅ **Pagination** - завантаження даних сторінками

## 🔒 Security Measures

### Реалізовані заходи безпеки:
- ✅ **Secure Storage** для API ключів (`flutter_secure_storage`)
- ✅ **Environment variables** для конфіденційних даних (`.env`)
- ✅ **Code obfuscation** для release build (Android ProGuard + Flutter Dart obfuscation)
- ✅ **Protected routes** - перевірка авторизації перед доступом
- ⚠️ **Password hashing** (в майбутньому)

### Code Obfuscation:
- ✅ **Android**: ProGuard налаштовано в `build.gradle.kts` (minifyEnabled, shrinkResources)
- ✅ **Flutter/Dart**: Автоматична obfuscation при використанні скриптів `build_release.sh` / `build_release.bat`
- ✅ **CI/CD**: Автоматична obfuscation в GitHub Actions workflow
- ⚠️ **Debug symbols**: Зберігаються окремо для можливості дебагу (не комітуються в git)

### Рекомендації для production:
- ✅ Code obfuscation налаштовано та автоматизовано
- Додати certificate pinning
- Реалізувати proper password hashing

## 📱 Screenshots

_(Додайте скріншоти додатку після тестування)_

## 🛠️ Технології

### State Management:
- **BLoC** / **Cubit** з `flutter_bloc`

### Dependency Injection:
- **GetIt**

### Local Storage:
- **Drift** - ORM для локальних баз даних, використовується для кешу, авторизації та колекцій
- **Hive** для user preferences
- **Secure Storage** для конфіденційних даних

### HTTP Client:
- **http** package
- **Dio** (в майбутньому для advanced features)

### UI:
- **Material Design 3**
- Custom widgets та animations
- Responsive design

## 📝 License

[Вказати ліцензію]

## 👥 Автори

[Ваше ім'я]

---

**Примітка**: Цей проект створено як індивідуальний проект для курсу Flutter розробки.
