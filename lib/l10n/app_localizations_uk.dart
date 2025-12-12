// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'Movie Discovery App';

  @override
  String get selectLanguage => 'Оберіть мову';

  @override
  String get ukrainian => 'Українська';

  @override
  String get english => 'English';

  @override
  String get appLanguage => 'Мова застосунку';

  @override
  String get appTheme => 'Тема застосунку';

  @override
  String get systemTheme => 'Системна';

  @override
  String get lightTheme => 'Світла';

  @override
  String get darkTheme => 'Темна';

  @override
  String get aboutApp => 'Про застосунок';

  @override
  String appVersion(String version) {
    return 'Версія застосунку: $version';
  }

  @override
  String version(String version) {
    return 'Версія: $version';
  }

  @override
  String get aboutAppDescription =>
      'У цьому застосунку ви можете знаходити нові фільми та серіали, керувати вибраним та переглядати персональні добірки.';

  @override
  String get settings => 'Налаштування';

  @override
  String get profile => 'Профіль';

  @override
  String get editProfile => 'Редагування профілю';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get enterEmail => 'Введіть email';

  @override
  String get invalidEmail => 'Некоректний email';

  @override
  String get enterPassword => 'Введіть пароль';

  @override
  String get minPasswordLength => 'Мінімум 6 символів';

  @override
  String get signIn => 'Увійти';

  @override
  String get signUp => 'Зареєструватись';

  @override
  String get noAccount => 'Немає акаунта? Зареєструватись';

  @override
  String get hasAccount => 'Вже є акаунт? Увійти';

  @override
  String get skip => 'Пропустити';

  @override
  String get returnToStories => 'Повернись до своїх історій';

  @override
  String get createAccount => 'Створи акаунт та відкривай нове';

  @override
  String get login => 'Вхід';

  @override
  String get returnToViewing => 'Повернись до перегляду';

  @override
  String get createAccountQuick => 'Створи акаунт за хвилину';

  @override
  String get successfulLogin => 'Успішний вхід!';

  @override
  String get successfulRegistration => 'Реєстрація успішна!';

  @override
  String get watched => 'Переглянуті';

  @override
  String get favorites => 'Вподобані';

  @override
  String get signOut => 'Вийти з акаунта';

  @override
  String get editProfileButton => 'Редагувати профіль';

  @override
  String get username => 'Ім\'я користувача';

  @override
  String get canBeEmpty => 'Можна залишити порожнім';

  @override
  String get saveChanges => 'Зберегти зміни';

  @override
  String get changePassword => 'Змінити пароль';

  @override
  String get currentPassword => 'Поточний пароль';

  @override
  String get newPassword => 'Новий пароль';

  @override
  String get confirmPassword => 'Підтвердити пароль';

  @override
  String get fillAllFields => 'Заповніть всі поля';

  @override
  String get passwordsDoNotMatch => 'Паролі не співпадають';

  @override
  String get saving => 'Збереження...';

  @override
  String get save => 'Зберегти';

  @override
  String get passwordChanged => 'Пароль змінено';

  @override
  String profileUpdated(String email) {
    return 'Профіль оновлено ($email)';
  }

  @override
  String error(String error) {
    return 'Помилка: $error';
  }

  @override
  String get deleteAccount => 'Видалити акаунт';

  @override
  String get authorizeFirst => 'Спочатку авторизуйтеся';

  @override
  String get selectFromGallery => 'Обрати з галереї';

  @override
  String get takePhoto => 'Зробити фото';

  @override
  String get deleteAvatar => 'Видалити аватар';

  @override
  String get appThemeTitle => 'Тема застосунку';

  @override
  String get loading => 'Завантаження...';

  @override
  String get favoritesEmpty => 'Список вподобань порожній';

  @override
  String get favoritesLoginPrompt =>
      'Увійдіть, щоб зберігати улюблені фільми й серіали.';

  @override
  String get watchlistEmpty => 'Ще нічого не переглянуто';

  @override
  String get watchlistUnavailable => 'Переглянуті недоступні';

  @override
  String get watchlistLoginPrompt =>
      'Увійдіть, щоб бачити ваші переглянуті фільми та серіали.';

  @override
  String get searchHistory => 'Історія пошуку';

  @override
  String get clear => 'Очистити';

  @override
  String get searchHistoryEmpty => 'Історія пошуку порожня';

  @override
  String get searchHistoryUnavailable => 'Історія пошуку недоступна';

  @override
  String get searchHistoryLoginPrompt =>
      'Увійдіть, щоб зберігати та переглядати історію пошуку.';

  @override
  String get search => 'Пошук';

  @override
  String get searchWithFilters => 'Пошук за фільтрами';

  @override
  String get authorizationRequired => 'Потрібна авторизація';

  @override
  String get loginToAddToFavorites => 'Увійдіть, щоб додати до вподобань.';

  @override
  String get loginToAddMediaToFavorites =>
      'Увійдіть, щоб додавати медіа до вподобань.';

  @override
  String get popularMovies => 'Популярні фільми';

  @override
  String get popularTvShows => 'Популярні серіали';

  @override
  String get allMovies => 'Усі фільми';

  @override
  String get allTvShows => 'Усі серіали';

  @override
  String get more => 'Більше';

  @override
  String get noData => 'Немає даних';

  @override
  String get nothingFound => 'Нічого не знайдено';

  @override
  String get loadMore => 'Завантажити більше';

  @override
  String get headerSubtitle => 'Підібрали, що переглянути сьогодні';

  @override
  String get headerDescription =>
      'Продовжуй відкривати історії, додавай у вподобане та повертайся за рекомендаціями.';

  @override
  String get explore => 'Дослідити';

  @override
  String get trailer => 'Трейлер';

  @override
  String get overview => 'Опис';

  @override
  String get noOverview => 'Опис відсутній';

  @override
  String get characteristics => 'Характеристики';

  @override
  String get releaseDate => 'Дата виходу';

  @override
  String get genres => 'Жанри';

  @override
  String get status => 'Статус';

  @override
  String get voteCount => 'Кількість голосів';

  @override
  String get reviews => 'Відгуки';

  @override
  String get noReviewsYet => 'Ще немає відгуків';

  @override
  String get anonymous => 'Анонім';

  @override
  String get recommended => 'Рекомендовані';

  @override
  String get trailerUnavailable => 'Трейлер недоступний';

  @override
  String get videoUnavailable => 'Відео недоступне';

  @override
  String get tryingToFindAnotherVideo => 'Спробуємо знайти інше відео...';

  @override
  String get enterTitle => 'Введіть назву...';

  @override
  String get genre => 'Жанр';

  @override
  String get genreExample => 'Жанр (наприклад: Action, Comedy)';

  @override
  String get year => 'Рік';

  @override
  String get rating => 'Рейтинг';

  @override
  String get noInternetConnection =>
      'Немає інтернет-з\'єднання. Перевірте підключення до мережі.';

  @override
  String get timeoutError =>
      'Час очікування вичерпано. Перевірте інтернет-з\'єднання.';

  @override
  String get connectionError =>
      'Помилка підключення до сервера. Спробуйте пізніше.';

  @override
  String get insufficientPermissions =>
      'Недостатньо прав доступу. Увійдіть в акаунт.';

  @override
  String get nothingFoundWithFilters =>
      'Нічого не знайдено за заданими фільтрами. Спробуйте інші параметри пошуку.';

  @override
  String get searchFailed => 'Не вдалося виконати пошук. Спробуйте пізніше.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get home => 'Головна';

  @override
  String votes(int count) {
    return '$count голосів';
  }

  @override
  String minutes(int minutes) {
    return '$minutes хв';
  }

  @override
  String seasons(int count) {
    return 'Сезонів: $count';
  }
}
