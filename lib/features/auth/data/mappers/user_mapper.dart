import '../../domain/entities/user.dart';
import '../models/local_user.dart';

/// Mapper для конвертації між data model (LocalUser) та domain entity (User)
class UserMapper {
  /// Конвертує LocalUser (data model) в User (domain entity)
  static User toEntity(LocalUser localUser) {
    return User(
      id: localUser.id,
      email: localUser.email,
      displayName: localUser.displayName,
      avatarUrl: localUser.avatarUrl,
    );
  }

  /// Конвертує User (domain entity) в LocalUser (data model)
  ///
  /// Використовується для збереження в базу даних
  static LocalUser toDataModel(User user) {
    return LocalUser(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
    );
  }
}
