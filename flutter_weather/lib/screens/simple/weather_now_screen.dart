import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/weather_icons.dart';
import '../../widgets/weather_scaffold.dart';
import '../complex/day_details_screen.dart';
import '../complex/settings_screen.dart';
import 'city_list_screen.dart';

/// ПРОСТОЙ МАКЕТ №1 — текущая погода.
///
/// Элементы интерфейса: [Scaffold] [SafeArea] [Column] [Row] [Spacer]
/// [CustomScrollView] [GlassCard] [CustomPaint] [AnimatedCounter] [SnackBar].
class WeatherNowScreen extends StatelessWidget {
  const WeatherNowScreen({super.key});

  /// Ниже этой ширины метрики перестают помещаться в одну строку.
  static const double _minInlineMetricsWidth = 340;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final CityWeather data = SampleWeather.of(state.selectedCity);
    final City city = data.city;
    final bool night = state.isNightFor(city.kind, city.updated);
    final int temp = state.tempUnit.of(city.temp);

    return WeatherScaffold(
      kind: city.kind,
      time: city.updated,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              city.name,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            Text(
              city.region,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          SkyButton(
            icon: Icons.search_rounded,
            tooltip: 'Найти город',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const CityListScreen(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SkyButton(
            icon: Icons.settings_rounded,
            tooltip: 'Настройки',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const SettingsScreen(),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 8),
            Center(
              child: WeatherGlyph(kind: city.kind, size: 132, night: night),
            ),
            const SizedBox(height: 4),
            // Крупная температура — визитная карточка экрана.
            Center(
              child: AnimatedCounter(
                value: temp,
                style: const TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w200,
                  height: 1.0,
                  letterSpacing: -4,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                city.condition,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Макс. ${state.tempUnit.of(city.tempMax)}°  ·  '
                'Мин. ${state.tempUnit.of(city.tempMin)}°',
                style: TextStyle(
                  fontSize: 14.5,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 22),

            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  final List<Widget> tiles = <Widget>[
                    MetricTile(
                      icon: Icons.thermostat_rounded,
                      label: 'Ощущается',
                      value: '${state.tempUnit.of(city.feelsLike)}',
                      unit: '°',
                    ),
                    MetricTile(
                      icon: Icons.air_rounded,
                      label: 'Ветер',
                      value: '${state.windUnit.of(city.windSpeed)}',
                      unit: state.windUnit.label,
                    ),
                    MetricTile(
                      icon: Icons.water_drop_outlined,
                      label: 'Влажность',
                      value: '${city.humidity}',
                      unit: '%',
                    ),
                    MetricTile(
                      icon: Icons.speed_rounded,
                      label: 'Давление',
                      value: '${city.pressure}',
                      unit: 'мм',
                    ),
                  ];

                  // На узком экране четыре метрики в строку не помещаются:
                  // переносим их в сетку 2×2.
                  if (c.maxWidth < _minInlineMetricsWidth) {
                    final double w = (c.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 16,
                      children: <Widget>[
                        for (final Widget tile in tiles)
                          SizedBox(width: w, child: tile),
                      ],
                    );
                  }

                  return Row(
                    children: <Widget>[
                      for (final Widget tile in tiles) Expanded(child: tile),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            GlassCard(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _CardTitle('Ближайшие часы'),
                  const SizedBox(height: 14),
                  // Высота подобрана так, чтобы полоса помещалась
                  // и при увеличенном масштабе шрифта.
                  SizedBox(
                    height: MediaQuery.textScalerOf(context).scale(112),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 8,
                      separatorBuilder: (_, _) => const SizedBox(width: 18),
                      itemBuilder: (BuildContext context, int i) {
                        final HourlyPoint point = data.hourly[i];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              point.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            WeatherGlyph(
                              kind: point.kind,
                              size: 26,
                              night: night,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${state.tempUnit.of(point.temp)}°',
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const DayDetailsScreen(),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Прогноз на сегодня'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Center(
              child: Text(
                'Обновлено в ${_hhmm(city.updated)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

/// Заголовок секции внутри стеклянной карточки.
class _CardTitle extends StatelessWidget {
  const _CardTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}
