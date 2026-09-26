import 'dart:math' as math;

import 'models.dart';

/// Демонстрационные данные прогноза погоды.
class SampleWeather {
  const SampleWeather._();

  /// Кривая температуры за сутки: минимум около 5:00, максимум около 15:00.
  static List<HourlyPoint> _hourly({
    required int tempMin,
    required int tempMax,
    required WeatherKind dayKind,
    required WeatherKind nightKind,
    List<int>? precip,
  }) {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ).subtract(const Duration(hours: 1));
    final int mid = (tempMin + tempMax) ~/ 2;
    final int amp = (tempMax - tempMin) ~/ 2;

    return List<HourlyPoint>.generate(24, (int i) {
      final DateTime t = start.add(Duration(hours: i));
      final double phase = t.hour / 24.0 * 2 * math.pi;
      final int temp = mid - (amp * math.cos(phase)).round();
      final bool isDay = t.hour >= 7 && t.hour < 20;
      return HourlyPoint(
        time: t,
        temp: temp,
        kind: isDay ? dayKind : nightKind,
        precipitation: precip?[i % precip.length] ?? 0,
      );
    });
  }

  static List<DayForecast> _daily(
    List<(int, int, WeatherKind, String, int)> raw,
  ) {
    final DateTime today = DateTime.now();
    return <DayForecast>[
      for (int i = 0; i < raw.length; i++)
        DayForecast(
          date: today.add(Duration(days: i)),
          tempMin: raw[i].$1,
          tempMax: raw[i].$2,
          kind: raw[i].$3,
          condition: raw[i].$4,
          precipitation: raw[i].$5,
        ),
    ];
  }

  static final List<(String, String, String)> _cityMeta =
      <(String, String, String)>[
        ('Москва', 'Россия', 'Московская обл.'),
        ('Санкт-Петербург', 'Россия', 'Ленинградская обл.'),
        ('Сочи', 'Россия', 'Краснодарский край'),
        ('Казань', 'Россия', 'Республика Татарстан'),
        ('Екатеринбург', 'Россия', 'Свердловская обл.'),
        ('Владивосток', 'Россия', 'Приморский край'),
      ];

  static final Map<String, CityWeather> _data = <String, CityWeather>{
    'Москва': CityWeather(
      city: City(
        name: 'Москва',
        country: 'Россия',
        region: 'Московская обл.',
        temp: 24,
        feelsLike: 25,
        tempMin: 16,
        tempMax: 27,
        kind: WeatherKind.partlyCloudy,
        condition: 'Переменная облачность',
        humidity: 52,
        pressure: 1014,
        windSpeed: 11,
        updated: DateTime.now(),
      ),
      hourly: _hourly(
        tempMin: 16,
        tempMax: 27,
        dayKind: WeatherKind.partlyCloudy,
        nightKind: WeatherKind.clear,
        precip: const <int>[5, 10, 5, 0, 0, 15, 20],
      ),
      daily: _daily(const <(int, int, WeatherKind, String, int)>[
        (16, 27, WeatherKind.partlyCloudy, 'Переменная облачность', 12),
        (15, 25, WeatherKind.rain, 'Небольшой дождь', 78),
        (14, 22, WeatherKind.rain, 'Дождь', 90),
        (13, 21, WeatherKind.cloudy, 'Пасмурно', 40),
        (15, 24, WeatherKind.clear, 'Ясно', 5),
        (17, 28, WeatherKind.clear, 'Ясно', 0),
        (18, 30, WeatherKind.partlyCloudy, 'Малооблачно', 10),
      ]),
      windDeg: 225,
      uvIndex: 6,
      visibility: 12,
      dewPoint: 13,
      sunrise: DateTime(2026, 9, 26, 6, 32),
      sunset: DateTime(2026, 9, 26, 18, 41),
      pressureTrend: 2,
    ),
    'Санкт-Петербург': CityWeather(
      city: City(
        name: 'Санкт-Петербург',
        country: 'Россия',
        region: 'Ленинградская обл.',
        temp: 18,
        feelsLike: 16,
        tempMin: 13,
        tempMax: 20,
        kind: WeatherKind.cloudy,
        condition: 'Пасмурно',
        humidity: 71,
        pressure: 1008,
        windSpeed: 16,
        updated: DateTime.now(),
      ),
      hourly: _hourly(
        tempMin: 13,
        tempMax: 20,
        dayKind: WeatherKind.cloudy,
        nightKind: WeatherKind.rain,
        precip: const <int>[30, 45, 55, 40, 35, 25, 20],
      ),
      daily: _daily(const <(int, int, WeatherKind, String, int)>[
        (13, 20, WeatherKind.cloudy, 'Пасмурно', 35),
        (12, 18, WeatherKind.rain, 'Дождь', 85),
        (12, 17, WeatherKind.rain, 'Дождь', 92),
        (11, 16, WeatherKind.fog, 'Туман', 45),
        (12, 19, WeatherKind.partlyCloudy, 'Облачно с прояснениями', 25),
        (13, 21, WeatherKind.clear, 'Ясно', 8),
        (14, 22, WeatherKind.partlyCloudy, 'Малооблачно', 15),
      ]),
      windDeg: 280,
      uvIndex: 3,
      visibility: 9,
      dewPoint: 11,
      sunrise: DateTime(2026, 9, 26, 7, 4),
      sunset: DateTime(2026, 9, 26, 18, 58),
      pressureTrend: -3,
    ),
    'Сочи': CityWeather(
      city: City(
        name: 'Сочи',
        country: 'Россия',
        region: 'Краснодарский край',
        temp: 28,
        feelsLike: 32,
        tempMin: 23,
        tempMax: 30,
        kind: WeatherKind.clear,
        condition: 'Ясно',
        humidity: 64,
        pressure: 1010,
        windSpeed: 7,
        updated: DateTime.now(),
      ),
      hourly: _hourly(
        tempMin: 23,
        tempMax: 30,
        dayKind: WeatherKind.clear,
        nightKind: WeatherKind.clear,
        precip: const <int>[0, 0, 5, 0, 0, 0, 10],
      ),
      daily: _daily(const <(int, int, WeatherKind, String, int)>[
        (23, 30, WeatherKind.clear, 'Ясно', 0),
        (23, 29, WeatherKind.clear, 'Ясно', 5),
        (22, 28, WeatherKind.partlyCloudy, 'Малооблачно', 15),
        (22, 27, WeatherKind.rain, 'Кратковременный дождь', 70),
        (21, 26, WeatherKind.rain, 'Дождь', 85),
        (22, 28, WeatherKind.partlyCloudy, 'Облачно с прояснениями', 25),
        (23, 30, WeatherKind.clear, 'Ясно', 5),
      ]),
      windDeg: 190,
      uvIndex: 9,
      visibility: 15,
      dewPoint: 20,
      sunrise: DateTime(2026, 9, 26, 6, 48),
      sunset: DateTime(2026, 9, 26, 19, 4),
      pressureTrend: 0,
    ),
    'Казань': CityWeather(
      city: City(
        name: 'Казань',
        country: 'Россия',
        region: 'Республика Татарстан',
        temp: 21,
        feelsLike: 20,
        tempMin: 13,
        tempMax: 24,
        kind: WeatherKind.rain,
        condition: 'Небольшой дождь',
        humidity: 68,
        pressure: 1006,
        windSpeed: 19,
        updated: DateTime.now(),
      ),
      hourly: _hourly(
        tempMin: 13,
        tempMax: 24,
        dayKind: WeatherKind.rain,
        nightKind: WeatherKind.rain,
        precip: const <int>[60, 70, 55, 45, 50, 65, 75],
      ),
      daily: _daily(const <(int, int, WeatherKind, String, int)>[
        (13, 24, WeatherKind.rain, 'Небольшой дождь', 65),
        (12, 21, WeatherKind.rain, 'Дождь', 88),
        (11, 19, WeatherKind.thunder, 'Гроза', 80),
        (10, 18, WeatherKind.cloudy, 'Пасмурно', 35),
        (12, 21, WeatherKind.partlyCloudy, 'Облачно с прояснениями', 20),
        (13, 23, WeatherKind.clear, 'Ясно', 5),
        (14, 25, WeatherKind.clear, 'Ясно', 0),
      ]),
      windDeg: 250,
      uvIndex: 2,
      visibility: 7,
      dewPoint: 14,
      sunrise: DateTime(2026, 9, 26, 5, 58),
      sunset: DateTime(2026, 9, 26, 18, 14),
      pressureTrend: -5,
    ),
    'Екатеринбург': CityWeather(
      city: City(
        name: 'Екатеринбург',
        country: 'Россия',
        region: 'Свердловская обл.',
        temp: 14,
        feelsLike: 12,
        tempMin: 7,
        tempMax: 17,
        kind: WeatherKind.fog,
        condition: 'Туман',
        humidity: 82,
        pressure: 1021,
        windSpeed: 6,
        updated: DateTime.now(),
      ),
      hourly: _hourly(
        tempMin: 7,
        tempMax: 17,
        dayKind: WeatherKind.fog,
        nightKind: WeatherKind.fog,
        precip: const <int>[20, 20, 15, 10, 10, 15, 20],
      ),
      daily: _daily(const <(int, int, WeatherKind, String, int)>[
        (7, 17, WeatherKind.fog, 'Туман', 20),
        (6, 16, WeatherKind.cloudy, 'Пасмурно', 30),
        (5, 14, WeatherKind.rain, 'Дождь', 75),
        (4, 13, WeatherKind.snow, 'Снег', 90),
        (3, 11, WeatherKind.snow, 'Снегопад', 95),
        (2, 10, WeatherKind.partlyCloudy, 'Переменная облачность', 40),
        (3, 12, WeatherKind.clear, 'Ясно', 10),
      ]),
      windDeg: 300,
      uvIndex: 1,
      visibility: 4,
      dewPoint: 5,
      sunrise: DateTime(2026, 9, 26, 6, 44),
      sunset: DateTime(2026, 9, 26, 18, 26),
      pressureTrend: 6,
    ),
    'Владивосток': CityWeather(
      city: City(
        name: 'Владивосток',
        country: 'Россия',
        region: 'Приморский край',
        temp: 19,
        feelsLike: 20,
        tempMin: 15,
        tempMax: 22,
        kind: WeatherKind.thunder,
        condition: 'Гроза',
        humidity: 79,
        pressure: 1004,
        windSpeed: 22,
        updated: DateTime.now(),
      ),
      hourly: _hourly(
        tempMin: 15,
        tempMax: 22,
        dayKind: WeatherKind.thunder,
        nightKind: WeatherKind.rain,
        precip: const <int>[55, 65, 75, 60, 50, 45, 40],
      ),
      daily: _daily(const <(int, int, WeatherKind, String, int)>[
        (15, 22, WeatherKind.thunder, 'Гроза', 70),
        (15, 21, WeatherKind.rain, 'Дождь', 85),
        (14, 20, WeatherKind.rain, 'Дождь', 90),
        (13, 19, WeatherKind.cloudy, 'Пасмурно', 45),
        (14, 21, WeatherKind.partlyCloudy, 'Облачно с прояснениями', 25),
        (15, 22, WeatherKind.clear, 'Ясно', 10),
        (16, 23, WeatherKind.partlyCloudy, 'Малооблачно', 15),
      ]),
      windDeg: 200,
      uvIndex: 4,
      visibility: 10,
      dewPoint: 15,
      sunrise: DateTime(2026, 9, 26, 6, 12),
      sunset: DateTime(2026, 9, 26, 18, 6),
      pressureTrend: -8,
    ),
  };

  /// Список городов для экрана выбора.
  static List<City> get cities =>
      _data.values.map((CityWeather w) => w.city).toList(growable: false);

  /// Полные данные по городу.
  static CityWeather of(String city) => _data[city] ?? _data.values.first;

  /// Город по умолчанию.
  static CityWeather get defaultCity => _data['Москва']!;

  /// Названия городов — источник для формы добавления.
  static List<String> get cityNames => _cityMeta.map((c) => c.$1).toList();

  /// Регион по названию города.
  static String regionOf(String city) => _cityMeta
      .firstWhere((c) => c.$1 == city, orElse: () => (city, '', ''))
      .$3;

  /// Страна по названию города.
  static String countryOf(String city) => _cityMeta
      .firstWhere((c) => c.$1 == city, orElse: () => (city, '', 'Россия'))
      .$2;
}
