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
- **Offline-first**: кешування даних в SQLite через `LocalCacheDb`
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
- Локальна авторизація через SQLite
- Збереження сесії користувача
- Захищені маршрути

## 📁 Структура проекту

```
project/
├── lib/
│   ├── core/              # Utils, constants, DI, domain base classes
│   │   ├── domain/        # Base use case classes
│   │   ├── network/       # Network configuration
│   │   ├── storage/        # Local storage (SQLite, Secure Storage)
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
- ✅ **Widget tests**: базові тести UI компонентів
- ⚠️ **Unit tests**: потрібно розширити покриття
- ⚠️ **Integration tests**: потрібно додати E2E тести

### Плани:
- Мінімум 70% code coverage
- Unit tests для use cases та repositories
- Widget tests для всіх основних компонентів
- Integration tests для ключових user flows

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
   - Створити файл `.env` в корені проекту
   - Додати TMDB API ключ:
     ```
     TMDB_API_KEY=your_api_key_here
     ```

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

### Для запуску тестів:
```bash
flutter test
flutter test --coverage
```

## 🔧 CI/CD

Проект використовує **GitHub Actions** для автоматизації:

### Workflow файл: `.github/workflows/flutter.yml`

**Після кожного push/PR виконується:**

1. **Test Job:**
   - Перевірка форматування коду
   - Аналіз коду (`flutter analyze`)
   - Запуск тестів з покриттям
   - Завантаження coverage на codecov

2. **Build Job:**
   - Збірка release APK
   - Завантаження артефакту APK

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
- ✅ **Local caching** - кешування API відповідей в SQLite
- ✅ **Pagination** - завантаження даних сторінками

## 🔒 Security Measures

### Реалізовані заходи безпеки:
- ✅ **Secure Storage** для API ключів (`flutter_secure_storage`)
- ✅ **Environment variables** для конфіденційних даних (`.env`)
- ✅ **Password hashing** (в майбутньому)
- ✅ **Protected routes** - перевірка авторизації перед доступом

### Рекомендації для production:
- Використовувати code obfuscation для release build
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
- **SQLite** через `sqflite` та `drift`
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
