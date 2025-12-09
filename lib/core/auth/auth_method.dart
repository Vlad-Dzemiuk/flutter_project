/// Метод аутентифікації
enum AuthMethod {
  /// Локальна база даних (Drift/SQLite)
  local,
  
  /// Firebase Authentication
  firebase,
  
  /// Mock API з JWT tokens
  jwt,
}

