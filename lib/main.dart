import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/view/pages/splash_screen.dart';

import 'package:doctor_appointment_app/view_model/settings.dart';

import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/routes/routes.dart';
import 'package:doctor_appointment_app/utils/config.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';

import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  setPathUrlStrategy();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    ProviderScope(
      child: const MyApp(),
      retry: (retryCount, error) {
        if (retryCount > 3) {
          return null;
        }
        return const Duration(seconds: 2);
      },
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return GetMaterialApp(
      title: 'Flutter Doctor App',
      debugShowCheckedModeBanner: false,
      theme: Config.lightTheme,

      initialRoute: Sroutes.auth,
      getPages: SAppRoute.pages,
      darkTheme: Config.darkTheme,
      locale: settingsAsync.maybeWhen(
        data: (data) => Locale(data['lang']),
        orElse: () => const Locale('en'),
      ),
      fallbackLocale: const Locale('en'),
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: settingsAsync.maybeWhen(
        data: (data) {
          return data['theme'];
        },
        orElse: () {
          return ThemeMode.system;
        },
      ),
      builder: (context, child) {
        return settingsAsync.when(
          data: (_) {
            return child!;
          },
          loading: () => const SplashScreen(),
          error: (err, _) => Scaffold(
            body: Center(child: Text('Error loading settings: $err')),
          ),
        );
      },
    );
  }
}
