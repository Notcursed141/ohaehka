import 'package:flutter/material.dart';

import '../data/models.dart';

/// Общее состояние приложения.
///
/// Хранит настройки, которые нужны на нескольких экранах: тему,
/// единицы измерения, выбранный и сохранённые города. Доступ к нему
/// идёт через [AppScope], чтобы не тянуть сторонние пакеты состояния.
class AppState extends ChangeNotifier {
  AppState({
    this.themeMode = ThemeMode.light,
    this.tempUnit = TempUnit.celsius,
    this.windUnit = WindUnit.kmh,
    this.selectedCity = 'Москва',
    this.notifications = true,
    this.compactHourly = true,
    List<String>? savedCities,
  }) : savedCities =
           savedCities ?? <String>['Москва', 'Санкт-Петербург', 'Сочи'];

  ThemeMode themeMode;
  TempUnit tempUnit;
  WindUnit windUnit;
  String selectedCity;
  bool notifications;

  /// Компактный почасовой прогноз: каждые 3 часа вместо каждого.
  bool compactHourly;
  final List<String> savedCities;

  bool isNightFor(WeatherKind kind, DateTime time) => isNight(kind, time);

  void setThemeMode(ThemeMode value) {
    if (themeMode == value) return;
    themeMode = value;
    notifyListeners();
  }

  void setTempUnit(TempUnit value) {
    if (tempUnit == value) return;
    tempUnit = value;
    notifyListeners();
  }

  void setWindUnit(WindUnit value) {
    if (windUnit == value) return;
    windUnit = value;
    notifyListeners();
  }

  void setNotifications(bool value) {
    if (notifications == value) return;
    notifications = value;
    notifyListeners();
  }

  void setCompactHourly(bool value) {
    if (compactHourly == value) return;
    compactHourly = value;
    notifyListeners();
  }

  void selectCity(String city) {
    if (selectedCity == city) return;
    selectedCity = city;
    notifyListeners();
  }

  void addCity(String city) {
    if (savedCities.contains(city)) return;
    savedCities.add(city);
    notifyListeners();
  }

  void removeCity(String city) {
    if (savedCities.length <= 1) return;
    savedCities.remove(city);
    if (selectedCity == city) {
      selectedCity = savedCities.first;
    }
    notifyListeners();
  }
}

/// Проксирует [AppState] вниз по дереву виджетов.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final AppScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope не найден в дереве виджетов');
    return scope!.notifier!;
  }
}
