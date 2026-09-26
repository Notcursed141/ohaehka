import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/sample_data.dart';
import '../state/app_state.dart';
import '../theme/weather_palette.dart';
import '../widgets/weather_icons.dart';
import 'complex/day_details_screen.dart';
import 'complex/settings_screen.dart';
import 'simple/city_list_screen.dart';
import 'simple/weather_now_screen.dart';

/// Описание одного макета для карточки в хабе.
class _Mockup {
  const _Mockup({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.icon,
    required this.builder,
    required this.widgets,
  });

  final int number;
  final String title;
  final String subtitle;
  final WeatherKind kind;
  final IconData icon;
  final WidgetBuilder builder;

  /// Виджеты Flutter, которые используются в макете.
  final List<String> widgets;
}

/// Стартовый экран: четыре макета, разбитые на две вкладки.
///
/// Элементы интерфейса: [DefaultTabController] [TabBar] [TabBarView]
/// [ListView] [Card] [InkWell] [Wrap] [Hero].
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_Mockup> _simple = <_Mockup>[
    _Mockup(
      number: 1,
      title: 'Текущая погода',
      subtitle:
          'Главный экран: город, крупная температура, иконка погоды, '
          'строка метрик и ближайшие часы',
      kind: WeatherKind.partlyCloudy,
      icon: Icons.wb_sunny_outlined,
      builder: _buildWeatherNow,
      widgets: <String>[
        'Scaffold',
        'SafeArea',
        'Column',
        'Row',
        'Spacer',
        'SingleChildScrollView',
        'GlassCard',
        'AnimatedCounter',
        'CustomPaint',
        'ListView',
        'SnackBar',
      ],
    ),
    _Mockup(
      number: 2,
      title: 'Мои города',
      subtitle:
          'Список сохранённых городов с живым поиском по названию и региону',
      kind: WeatherKind.cloudy,
      icon: Icons.location_city_rounded,
      builder: _buildCityList,
      widgets: <String>[
        'CustomScrollView',
        'SliverAppBar',
        'SliverList',
        'SliverFillRemaining',
        'TextField',
        'GlassCard',
        'FloatingActionButton',
        'SnackBar',
      ],
    ),
  ];

  static const List<_Mockup> _complex = <_Mockup>[
    _Mockup(
      number: 3,
      title: 'Прогноз на сегодня',
      subtitle:
          'График температуры по часам, дуга солнца, прогноз на неделю '
          'и сетка подробных метрик',
      kind: WeatherKind.rain,
      icon: Icons.timeline_rounded,
      builder: _buildDayDetails,
      widgets: <String>[
        'CustomScrollView',
        'SliverAppBar',
        'CustomPaint',
        'ScrollController',
        'LayoutBuilder',
        'Wrap',
        'AnimatedContainer',
        'LayoutBuilder',
        'SegmentedButton',
      ],
    ),
    _Mockup(
      number: 4,
      title: 'Настройки',
      subtitle:
          'Смена темы, единицы измерения, управление городами и форма '
          'добавления с валидацией',
      kind: WeatherKind.snow,
      icon: Icons.tune_rounded,
      builder: _buildSettings,
      widgets: <String>[
        'Form',
        'GlobalKey',
        'TextFormField',
        'Autocomplete',
        'DropdownButtonFormField',
        'SegmentedButton',
        'SwitchListTile',
        'Dismissible',
        'showModalBottomSheet',
      ],
    ),
  ];

  static Widget _buildWeatherNow(BuildContext _) => const WeatherNowScreen();
  static Widget _buildCityList(BuildContext _) => const CityListScreen();
  static Widget _buildDayDetails(BuildContext _) => const DayDetailsScreen();
  static Widget _buildSettings(BuildContext _) => const SettingsScreen();

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            const _Header(),
            Material(
              color: Theme.of(context).colorScheme.surface,
              child: const TabBar(
                tabs: <Widget>[
                  Tab(text: 'Простые макеты'),
                  Tab(text: 'Сложные макеты'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _MockupList(items: _simple, state: state),
                  _MockupList(items: _complex, state: state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Шапка хаба: показывает погоду выбранного города.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final CityWeather data = SampleWeather.of(state.selectedCity);
    final City city = data.city;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 16,
        20,
        20,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF1D6FE0),
            Color(0xFF3E9BF0),
            Color(0xFF7FC7F5),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Погода',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Практическая работа · 4 макета',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      WeatherGlyph(
                        kind: city.kind,
                        size: 28,
                        night: state.isNightFor(city.kind, city.updated),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${city.name} · ${state.tempUnit.of(city.temp)}°',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const SettingsScreen(),
                ),
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Настройки',
            ),
          ],
        ),
      ),
    );
  }
}

/// Список карточек макетов на одной вкладке.
class _MockupList extends StatelessWidget {
  const _MockupList({required this.items, required this.state});

  final List<_Mockup> items;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: <Widget>[
        for (final _Mockup item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _MockupCard(item: item, state: state),
          ),
      ],
    );
  }
}

/// Карточка макета с мини-превью градиента и списком виджетов.
class _MockupCard extends StatelessWidget {
  const _MockupCard({required this.item, required this.state});

  final _Mockup item;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: item.builder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Превью: тот же градиент, что и на экране макета.
            Container(
              height: 92,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: WeatherPalette.of(item.kind, DateTime.now()).colors,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 22),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Макет ${item.number}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      for (final String w in item.widgets)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            w,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          'Открыть макет',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 17,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
