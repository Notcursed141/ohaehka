import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/temp_chart.dart';
import '../../widgets/weather_icons.dart';
import '../../widgets/weather_scaffold.dart';

/// СЛОЖНЫЙ МАКЕТ №1 — подробный прогноз на день и неделю.
///
/// Элементы интерфейса: [CustomScrollView] [SliverAppBar] [SliverToBoxAdapter]
/// [NestedScrollView]-подобная схема, [CustomPaint] для графика и дуги солнца,
/// [ListView.separated], [SegmentedButton], [Dismissible]-не нужен,
/// [AnimatedContainer], [GridView] сетка метрик.
class DayDetailsScreen extends StatelessWidget {
  const DayDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final CityWeather data = SampleWeather.of(state.selectedCity);
    final City city = data.city;
    final bool night = state.isNightFor(city.kind, city.updated);

    return WeatherScaffold(
      kind: city.kind,
      time: city.updated,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              city.name,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              'Прогноз на сегодня',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          // Переключение единиц прямо на экране.
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _UnitToggle(
              unit: state.tempUnit,
              onChanged: state.setTempUnit,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          _Header(city: city, night: night, unit: state.tempUnit),
          const SizedBox(height: 18),

          // Почасовой график.
          GlassCard(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(left: 6, bottom: 6),
                  child: Text(
                    'По часам',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                HourlyChart(
                  hourly: data.hourly,
                  unit: state.tempUnit,
                  night: night,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.water_drop_outlined,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Осадки за сутки: ${_precipTotal(data.hourly)}%',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Солнце.
          GlassCard(
            child: Column(
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Солнце',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SunPath(
                  progress: _sunProgress(
                    city.updated,
                    data.sunrise,
                    data.sunset,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _TimePill(
                      icon: Icons.wb_twilight_rounded,
                      label: 'Восход',
                      value: _hhmm(data.sunrise),
                    ),
                    _TimePill(
                      icon: Icons.nights_stay_rounded,
                      label: 'Закат',
                      value: _hhmm(data.sunset),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Недельная сводка.
          _WeekCard(data: data, unit: state.tempUnit),
          const SizedBox(height: 14),

          // Подробные метрики.
          _MetricsCard(data: data, state: state),
        ],
      ),
    );
  }

  static int _precipTotal(List<HourlyPoint> hourly) {
    int total = 0;
    for (final HourlyPoint h in hourly) {
      total += h.precipitation;
    }
    return total ~/ hourly.length;
  }

  static String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// Положение солнца на дуге: 0 до рассвета, 0.5 в полдень.
  static double _sunProgress(DateTime now, DateTime sunrise, DateTime sunset) {
    if (now.isBefore(sunrise)) return 0;
    if (now.isAfter(sunset)) return 1;
    final int total = sunset.difference(sunrise).inMinutes;
    if (total == 0) return 0.5;
    return now.difference(sunrise).inMinutes / total;
  }
}

/// Шапка с крупной температурой и условием.
class _Header extends StatelessWidget {
  const _Header({required this.city, required this.night, required this.unit});

  final City city;
  final bool night;
  final TempUnit unit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        // На узком экране иконка уменьшается, чтобы тексту осталось место.
        final double glyph = c.maxWidth < 320 ? 64.0 : 96.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    city.condition,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ощущается как ${unit.of(city.feelsLike)}°',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Wrap вместо Row: при крупном шрифте две подписи
                  // переносятся на вторую строку, а не вылезают.
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: <Widget>[
                      Text(
                        '↑ ${unit.of(city.tempMax)}°',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '↓ ${unit.of(city.tempMin)}°',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            WeatherGlyph(kind: city.kind, size: glyph, night: night),
          ],
        );
      },
    );
  }
}

/// Переключатель °C / °F.
class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.unit, required this.onChanged});

  final TempUnit unit;
  final ValueChanged<TempUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final TempUnit value in TempUnit.values)
            GestureDetector(
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: value == unit ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  value.short,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: value == unit
                        ? const Color(0xFF1D6FE0)
                        : Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 17, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Прогноз на 7 дней с градиентной полосой температур.
class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.data, required this.unit});

  final CityWeather data;
  final TempUnit unit;

  @override
  Widget build(BuildContext context) {
    final int weekMin = data.daily
        .map((DayForecast d) => unit.of(d.tempMin))
        .reduce((int a, int b) => a < b ? a : b);
    final int weekMax = data.daily
        .map((DayForecast d) => unit.of(d.tempMax))
        .reduce((int a, int b) => a > b ? a : b);
    final int span = (weekMax - weekMin).abs() < 1 ? 1 : weekMax - weekMin;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'На неделю',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < data.daily.length; i++) ...<Widget>[
            if (i > 0)
              Divider(color: Colors.white.withValues(alpha: 0.12), height: 18),
            _DayRow(
              day: data.daily[i],
              unit: unit,
              weekMin: weekMin,
              span: span,
            ),
          ],
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.unit,
    required this.weekMin,
    required this.span,
  });

  final DayForecast day;
  final TempUnit unit;
  final int weekMin;
  final int span;

  @override
  Widget build(BuildContext context) {
    final int lo = unit.of(day.tempMin);
    final int hi = unit.of(day.tempMax);
    // Доля, которую занимает день в недельном диапазоне температур.
    final double start = (lo - weekMin) / span;
    final double width = ((hi - lo) / span).clamp(0.12, 1.0);

    return Row(
      children: <Widget>[
        // Название дня тянущееся: при крупном шрифте «Сегодня» не
        // помещается в фиксированную колонку.
        Flexible(
          flex: 3,
          child: Text(
            day.shortTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        WeatherGlyph(kind: day.kind, size: 24),
        const SizedBox(width: 10),
        SizedBox(
          width: 34,
          child: Text(
            '$lo°',
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              return SizedBox(
                height: 6,
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Positioned(
                      left: c.maxWidth * start * (1 - width),
                      width: c.maxWidth * width,
                      top: 0,
                      bottom: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: <Color>[
                              Color(0xFF7FC7F5),
                              Color(0xFFFFD66B),
                              Color(0xFFFF8E53),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            '$hi°',
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Сетка подробных метрик.
class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.data, required this.state});

  final CityWeather data;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final List<(IconData, String, String, String?)> tiles =
        <(IconData, String, String, String?)>[
          (
            Icons.air_rounded,
            'Ветер',
            '${state.windUnit.of(data.city.windSpeed)}',
            state.windUnit.label,
          ),
          (
            Icons.water_drop_outlined,
            'Влажность',
            '${data.city.humidity}',
            '%',
          ),
          (Icons.speed_rounded, 'Давление', '${data.city.pressure}', 'мм'),
          (
            Icons.thermostat_rounded,
            'Точка росы',
            '${state.tempUnit.of(data.dewPoint)}',
            '°',
          ),
          (
            Icons.wb_sunny_outlined,
            'УФ-индекс',
            '${data.uvIndex}',
            _uvLabel(data.uvIndex),
          ),
          (Icons.visibility_outlined, 'Видимость', '${data.visibility}', 'км'),
        ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Подробности',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final double w = (c.maxWidth - 24) / 3;
              return Wrap(
                spacing: 12,
                runSpacing: 18,
                children: <Widget>[
                  for (final (
                        IconData icon,
                        String label,
                        String value,
                        String? unit,
                      )
                      in tiles)
                    SizedBox(
                      width: w,
                      child: MetricTile(
                        icon: icon,
                        label: label,
                        value: value,
                        unit: unit,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(
                data.pressureTrend >= 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.pressureTrend >= 0
                      ? 'Давление растёт на ${data.pressureTrend} мм — '
                            'погода улучшится'
                      : 'Давление падает на ${data.pressureTrend.abs()} мм — '
                            'возможен дождь',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _uvLabel(int uv) => switch (uv) {
    <= 2 => 'низкий',
    <= 5 => 'умеренный',
    <= 7 => 'высокий',
    <= 10 => 'очень высокий',
    _ => 'экстремальный',
  };
}
