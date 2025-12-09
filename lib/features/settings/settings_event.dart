import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class SetThemeModeEvent extends SettingsEvent {
  final ThemeMode themeMode;

  const SetThemeModeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class SetLanguageEvent extends SettingsEvent {
  final String languageCode;

  const SetLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

