import 'dart:async';
import 'package:doctor_appointment_app/services/local_storage_services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ----------------------------
// Provider
// ----------------------------
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, Map<String, dynamic>>(
      SettingsNotifier.new,
    );

// ----------------------------
// Notifier
// ----------------------------
class SettingsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  FutureOr<Map<String, dynamic>> build() {
    state = const AsyncValue.loading();

    // Load theme & language
    final themeStr = LocalStorageService.getTheme ?? 'system';
    final langStr = LocalStorageService.getLang ?? 'en';

    // Convert theme string to ThemeMode
    ThemeMode themeMode;
    switch (themeStr) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }
    // Return as a map
    return {
      'theme': themeMode,
      'lang': langStr,
    };
  }

  // ----------------------------
  // Update theme
  // ----------------------------
  Future<void> setTheme(String theme) async {
    state = const AsyncValue.loading();
    try {
    
      ThemeMode themeMode = state.value?['theme']??ThemeMode.system;
      if (await LocalStorageService.setTheme(theme)) {
        switch (theme) {
          case 'light':
            themeMode = ThemeMode.light;
            break;
          case 'dark':
            themeMode = ThemeMode.dark;

            break;
          default:
            themeMode = ThemeMode.system;
        }
      }
      // Keep current language
      final currentLang = state.value?['lang'] ?? 'en';

      // Update state
      state = AsyncValue.data({
        'theme': themeMode,
        'lang': currentLang,
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ----------------------------
  // Update language
  // ----------------------------
  Future<void> setLanguage(String lang) async {
    state = const AsyncValue.loading();
    try {
  
     
      String newLang=state.value?['lang']??'en';
      if (await LocalStorageService.setLang(lang)) {
        newLang = lang;
      }
      // Keep current theme
      final currentTheme = state.value?['theme'] ?? ThemeMode.system;

      // Update state
      state = AsyncValue.data({
        'theme': currentTheme,
        'lang': newLang,
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
