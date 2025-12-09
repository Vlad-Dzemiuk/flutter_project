import 'package:equatable/equatable.dart';

/// Domain entity для користувача
/// 
/// Це чиста domain entity без залежностей від data layer
class User extends Equatable {
  final int id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl];

  User copyWith({
    int? id,
    String? email,
    String? displayName,
    bool clearDisplayName = false,
    String? avatarUrl,
    bool clearAvatar = false,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
    );
  }
}

