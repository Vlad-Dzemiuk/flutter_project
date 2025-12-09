import 'package:equatable/equatable.dart';

/// Data model для користувача (для збереження в SQLite)
/// 
/// Це модель даних, яка відповідає структурі бази даних
class LocalUser extends Equatable {
  final int id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  const LocalUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl];
}


