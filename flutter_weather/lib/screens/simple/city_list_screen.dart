import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/weather_icons.dart';
import '../../widgets/weather_scaffold.dart';
import '../complex/settings_screen.dart';

/// ПРОСТОЙ МАКЕТ №2 — выбор города.
///
/// Элементы интерфейса: [CustomScrollView] [SliverAppBar] [SliverList]
/// [ListView.separated] [TextField] живого поиска [GlassCard]
/// [FloatingActionButton.extended].
class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<City> _visible(List<City> all) {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (City c) =>
              c.name.toLowerCase().contains(q) ||
              c.country.toLowerCase().contains(q) ||
              c.region.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final List<City> cities = state.savedCities
        .map(SampleWeather.of)
        .map((CityWeather w) => w.city)
        .toList();
    final List<City> items = _visible(cities);

    return WeatherScaffold(
      kind: WeatherKind.partlyCloudy,
      time: DateTime.now(),
      appBar: AppBar(
        title: const Text(
          'Мои города',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          SkyButton(
            icon: Icons.tune_rounded,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                const SettingsScreen(openAddCity: true),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D6FE0),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Добавить',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: _search,
                  onChanged: (String v) => setState(() => _query = v),
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: Colors.white, fontSize: 15.5),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Поиск города',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                    ),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
              ),
            ),
          ),

          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.location_off_rounded,
                      size: 46,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Город не найден',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Попробуйте другое название',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int i) {
                  final City city = items[i];
                  final bool isActive = city.name == state.selectedCity;
                  final CityWeather data = SampleWeather.of(city.name);
                  final bool night = state.isNightFor(
                    city.kind,
                    data.city.updated,
                  );

                  return GlassCard(
                    opacity: isActive ? 0.28 : 0.14,
                    onTap: () {
                      state.selectCity(city.name);
                      showSkySnackBar(
                        context,
                        'Город ${city.name} выбран',
                        icon: Icons.check_rounded,
                      );
                      Navigator.of(context).maybePop();
                    },
                    child: Row(
                      children: <Widget>[
                        WeatherGlyph(kind: city.kind, size: 44, night: night),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      city.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (isActive) ...<Widget>[
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${city.condition}  ·  '
                                '${state.tempUnit.of(city.tempMin)}…'
                                '${state.tempUnit.of(city.tempMax)}°',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${state.tempUnit.of(city.temp)}°',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
