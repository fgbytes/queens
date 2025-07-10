import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A [Cubit] that manages the [ThemeMode] of the application.
class ThemeCubit extends Cubit<ThemeMode> {
  /// {@macro theme_cubit}
  ThemeCubit() : super(ThemeMode.system);

  /// Sets the theme to the given [ThemeMode].
  void setTheme(ThemeMode themeMode) {
    emit(themeMode);
  }
} 