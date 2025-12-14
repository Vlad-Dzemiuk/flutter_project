import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String languageCode;
  final bool loading;
  final String error;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'en',
    this.loading = false,
    this.error = '',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? loading,
    String? error,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [themeMode, languageCode, loading, error];
}
