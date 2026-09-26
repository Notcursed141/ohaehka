/// Тип погодного явления. От него зависят иконка и градиент неба.
enum WeatherKind { clear, partlyCloudy, cloudy, rain, thunder, snow, fog }

/// Условие, при котором в тёмную тему включается ночное небо.
bool isNight(WeatherKind kind, DateTime time) {
  final int hour = time.hour;
  final bool isDark = hour >= 20 || hour < 6;
  if (!isDark) return false;
  return kind == WeatherKind.clear || kind == WeatherKind.partlyCloudy;
}

/// Город с текущей погодой.
class City {
  const City({
    required this.name,
    required this.country,
    required this.region,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.kind,
    required this.condition,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.updated,
  });

  final String name;
  final String country;

  /// Область / регион, показывается мелким шрифтом под названием.
  final String region;
  final int temp;
  final int feelsLike;
  final int tempMin;
  final int tempMax;
  final WeatherKind kind;
  final String condition;
  final int humidity;
  final int pressure;
  final int windSpeed;
  final DateTime updated;

  /// Короткая подпись для списка городов.
  String get shortLabel => '$name, $country';
}

/// Точка почасового прогноза.
class HourlyPoint {
  const HourlyPoint({
    required this.time,
    required this.temp,
    required this.kind,
    required this.precipitation,
  });

  final DateTime time;
  final int temp;
  final WeatherKind kind;

  /// Вероятность осадков, проценты.
  final int precipitation;

  /// Подпись часа: «15» или «пн», если день другой.
  String get label {
    if (time.day != DateTime.now().day) {
      const List<String> days = <String>[
        'пн',
        'вт',
        'ср',
        'чт',
        'пт',
        'сб',
        'вс',
      ];
      return days[time.weekday - 1];
    }
    return '${time.hour}:00';
  }

  /// Подпись для графика: короткая, без двоеточия.
  String get shortLabel =>
      time.day == DateTime.now().day ? '${time.hour}' : label;
}

/// Прогноз на один день.
class DayForecast {
  const DayForecast({
    required this.date,
    required this.kind,
    required this.condition,
    required this.tempMin,
    required this.tempMax,
    required this.precipitation,
  });

  final DateTime date;
  final WeatherKind kind;
  final String condition;
  final int tempMin;
  final int tempMax;
  final int precipitation;

  /// Название дня: «Сегодня», «Завтра» или день недели.
  String get title {
    final DateTime today = DateTime.now();
    if (date.day == today.day) return 'Сегодня';
    if (date.day == today.add(const Duration(days: 1)).day) return 'Завтра';
    const List<String> days = <String>[
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    return days[date.weekday - 1];
  }

  String get shortTitle {
    final DateTime today = DateTime.now();
    if (date.day == today.day) return 'Сегодня';
    if (date.day == today.add(const Duration(days: 1)).day) return 'Завтра';
    const List<String> days = <String>[
      'пн',
      'вт',
      'ср',
      'чт',
      'пт',
      'сб',
      'вс',
    ];
    return days[date.weekday - 1];
  }
}

/// Полный набор данных по одному городу.
class CityWeather {
  const CityWeather({
    required this.city,
    required this.hourly,
    required this.daily,
    required this.windDeg,
    required this.uvIndex,
    required this.visibility,
    required this.dewPoint,
    required this.sunrise,
    required this.sunset,
    required this.pressureTrend,
  });

  final City city;
  final List<HourlyPoint> hourly;
  final List<DayForecast> daily;
  final int windDeg;
  final int uvIndex;
  final int visibility;
  final int dewPoint;
  final DateTime sunrise;
  final DateTime sunset;

  /// Изменение давления за сутки, в мм рт. ст.
  final int pressureTrend;

  /// Самая холодная точка почасового прогноза.
  int get minHourly =>
      hourly.map((HourlyPoint h) => h.temp).reduce((a, b) => a < b ? a : b);

  /// Самая тёплая точка почасового прогноза.
  int get maxHourly =>
      hourly.map((HourlyPoint h) => h.temp).reduce((a, b) => a > b ? a : b);
}

/// Единица измерения температуры.
enum TempUnit {
  celsius('°C', 'C'),
  fahrenheit('°F', 'F');

  const TempUnit(this.symbol, this.short);

  final String symbol;
  final String short;

  /// Переводит температуру в выбранную единицу и округляет.
  int of(int celsius) => switch (this) {
    TempUnit.celsius => celsius,
    TempUnit.fahrenheit => (celsius * 9 / 5 + 32).round(),
  };
}

/// Скорость ветра в выбранных единицах.
enum WindUnit {
  kmh('км/ч', 1),
  ms('м/с', 0.278),
  mph('mph', 0.447);

  const WindUnit(this.label, this.factor);

  final String label;

  /// Множитель для перевода из км/ч.
  final double factor;

  int of(int kmh) => (kmh * factor).round();
}
