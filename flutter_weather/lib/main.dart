import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppScope(state: AppState(), child: const WeatherApp()));
}

/// Корневой виджет приложения.
///
/// Тема переключается в настройках: [MaterialApp] подписан на [AppState]
/// через [AppScope], поэтому смена темы сразу видна на всех экранах.
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return MaterialApp(
      title: 'Погода',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: state.themeMode,
      home: const HomeScreen(),
    );
  }
}
