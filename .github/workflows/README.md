# CI/CD Pipeline Documentation

## Огляд

Цей CI/CD pipeline автоматично виконує наступні завдання при кожному push або pull request:

1. **Code Quality Check** - перевірка форматування та аналіз коду
2. **Unit Tests** - запуск unit тестів з покриттям коду
3. **Widget Tests** - запуск widget тестів з покриттям коду
4. **Coverage Report** - генерація комбінованого звіту про покриття коду
5. **Build APK** - збірка release APK з obfuscation
6. **Integration Tests** - запуск integration тестів на Android емуляторі (опціонально)

## Налаштування GitHub Secrets

Для роботи pipeline потрібно налаштувати наступні secrets в GitHub:

1. Перейдіть в **Settings** → **Secrets and variables** → **Actions**
2. Додайте secret:
   - `TMDB_API_KEY` - ваш TMDB API ключ

## Артефакти

Після успішного виконання pipeline будуть доступні наступні артефакти:

- **release-apk** - готовий APK файл для тестування (зберігається 90 днів)
- **debug-symbols** - символи для дебагу obfuscated коду (зберігається 90 днів)
- **combined-coverage-report** - HTML звіт про покриття коду (зберігається 30 днів)
- **unit-test-coverage** - покриття від unit тестів (зберігається 30 днів)
- **widget-test-coverage** - покриття від widget тестів (зберігається 30 днів)

## Запуск вручну

Pipeline можна запустити вручну через GitHub Actions UI:
1. Перейдіть до вкладки **Actions**
2. Виберіть workflow **Flutter CI/CD**
3. Натисніть **Run workflow**

## Вимкнення Integration Tests

Якщо потрібно тимчасово вимкнути integration тести (через тривалість виконання), розкоментуйте рядок `# if: false` в job `integration-tests`.

## Покриття коду

Coverage звіти генеруються автоматично та включають:
- Комбіноване покриття від unit та widget тестів
- HTML звіт для детального перегляду
- Статистику покриття в GitHub Actions summary

Для перегляду детального звіту:
1. Завантажте артефакт `combined-coverage-report`
2. Відкрийте файл `coverage/html/index.html` в браузері


