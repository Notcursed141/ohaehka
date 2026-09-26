import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../../state/app_state.dart';
import '../../widgets/weather_icons.dart';
import '../../widgets/weather_scaffold.dart';

/// СЛОЖНЫЙ МАКЕТ №2 — настройки и управление городами.
///
/// Элементы интерфейса: [Form] [GlobalKey] [TextFormField] [DropdownButtonFormField]
/// [Autocomplete] [SegmentedButton] [SwitchListTile] [Dismissible] [showModalBottomSheet]
/// [Scaffold] [ListView] [Card] [FilledButton].
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.openAddCity = false});

  /// Сразу открыть форму добавления города.
  final bool openAddCity;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openAddCity) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openAddCity());
    }
  }

  void _openAddCity() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const _AddCitySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: <Widget>[
          _Section(
            title: 'Внешний вид',
            icon: Icons.palette_outlined,
            child: SegmentedButton<ThemeMode>(
              segments: const <ButtonSegment<ThemeMode>>[
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined, size: 18),
                  label: Text('Светлая'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined, size: 18),
                  label: Text('Тёмная'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined, size: 18),
                  label: Text('Система'),
                ),
              ],
              selected: <ThemeMode>{state.themeMode},
              showSelectedIcon: false,
              onSelectionChanged: (Set<ThemeMode> value) =>
                  state.setThemeMode(value.first),
            ),
          ),

          _Section(
            title: 'Единицы измерения',
            icon: Icons.straighten_rounded,
            child: Column(
              children: <Widget>[
                _UnitRow<TempUnit>(
                  label: 'Температура',
                  unit: state.tempUnit,
                  values: TempUnit.values,
                  onChanged: state.setTempUnit,
                ),
                const Divider(height: 24),
                _UnitRow<WindUnit>(
                  label: 'Скорость ветра',
                  unit: state.windUnit,
                  values: WindUnit.values,
                  onChanged: state.setWindUnit,
                ),
              ],
            ),
          ),

          _Section(
            title: 'Мои города',
            icon: Icons.location_city_rounded,
            trailing: TextButton.icon(
              onPressed: _openAddCity,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Добавить'),
            ),
            child: Column(
              children: <Widget>[
                for (final String name in state.savedCities) ...<Widget>[
                  _CityTile(name: name, isActive: name == state.selectedCity),
                  if (name != state.savedCities.last)
                    Divider(
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                      height: 1,
                    ),
                ],
                if (state.savedCities.length == 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Это последний город — удалить его нельзя',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          _Section(
            title: 'Уведомления',
            icon: Icons.notifications_outlined,
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: state.notifications,
                  onChanged: state.setNotifications,
                  title: const Text('Прогноз на сегодня'),
                  subtitle: const Text('Уведомлять о погоде утром'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: state.compactHourly,
                  onChanged: state.setCompactHourly,
                  title: const Text('Компактный почасовой прогноз'),
                  subtitle: const Text('Показывать интервал в 3 часа'),
                ),
              ],
            ),
          ),

          _Section(
            title: 'О приложении',
            icon: Icons.info_outline_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _InfoRow(label: 'Название', value: 'Погода'),
                _InfoRow(label: 'Версия', value: '1.0.0'),
                _InfoRow(label: 'Макетов', value: '4 (2 простых, 2 сложных)'),
                _InfoRow(label: 'Данные', value: 'Демонстрационные, без сети'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Карточка-секция настроек.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, size: 19, color: scheme.primary),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  if (trailing != null) ?trailing,
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Строка выбора единицы измерения.
class _UnitRow<T> extends StatelessWidget {
  const _UnitRow({
    required this.label,
    required this.unit,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final T unit;
  final List<T> values;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final String title = label;
    final Widget picker = SegmentedButton<T>(
      segments: <ButtonSegment<T>>[
        for (final T value in values)
          ButtonSegment<T>(value: value, label: Text(_labelOf(value))),
      ],
      selected: <T>{unit},
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
      onSelectionChanged: (Set<T> value) => onChanged(value.first),
    );

    final Text titleText = Text(
      title,
      style: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    // На узком экране при крупном шрифте подпись и переключатель
    // не помещаются в строку — переносим подпись над переключателем.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        if (c.maxWidth >= _minInlineWidth) {
          return Row(
            children: <Widget>[
              Expanded(child: titleText),
              picker,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[titleText, const SizedBox(height: 10), picker],
        );
      },
    );
  }

  /// Ниже этой ширины строка переключателя становится слишком тесной.
  static const double _minInlineWidth = 300;

  static String _labelOf<T>(T value) => switch (value) {
    final TempUnit u => u.symbol,
    final WindUnit u => u.label,
    _ => '$value',
  };
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(fontSize: 13.5, color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Строка города со смахиванием для удаления.
class _CityTile extends StatelessWidget {
  const _CityTile({required this.name, required this.isActive});

  final String name;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final CityWeather data = SampleWeather.of(name);
    final City city = data.city;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey<String>(name),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: scheme.errorContainer,
        child: Icon(
          Icons.delete_outline_rounded,
          color: scheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) {
        state.removeCity(name);
        showSkySnackBar(
          context,
          'Город $name удалён',
          icon: Icons.delete_outline_rounded,
        );
      },
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () {
          state.selectCity(name);
          showSkySnackBar(context, 'Город $name выбран');
        },
        leading: WeatherGlyph(
          kind: city.kind,
          size: 32,
          night: state.isNightFor(city.kind, city.updated),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${city.condition} · ${state.tempUnit.of(city.temp)}°',
          style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
        ),
        trailing: isActive
            ? Icon(Icons.check_circle_rounded, color: scheme.primary, size: 20)
            : Text(
                '${state.tempUnit.of(city.tempMin)}…${state.tempUnit.of(city.tempMax)}°',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
      ),
    );
  }
}

/// Форма добавления города с валидацией.
class _AddCitySheet extends StatefulWidget {
  const _AddCitySheet();

  @override
  State<_AddCitySheet> createState() => _AddCitySheetState();
}

class _AddCitySheetState extends State<_AddCitySheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _nickname = TextEditingController();
  String _country = 'Россия';
  bool _isMain = false;

  @override
  void dispose() {
    _name.dispose();
    _nickname.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final AppState state = AppScope.of(context);
    final String name = _name.text.trim();
    final String display = _nickname.text.trim().isEmpty
        ? name
        : _nickname.text.trim();

    if (state.savedCities.contains(display)) {
      showSkySnackBar(
        context,
        'Город $display уже есть в списке',
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    state.addCity(display);
    if (_isMain) state.selectCity(display);

    Navigator.of(context).pop();
    showSkySnackBar(
      context,
      'Город $display добавлен',
      icon: Icons.check_circle_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<String> countries = <String>[
      'Россия',
      'Беларусь',
      'Казахстан',
      'Кыргызстан',
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Новый город',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 18),

                Autocomplete<String>(
                  initialValue: TextEditingValue(text: _name.text),
                  displayStringForOption: (String o) => o,
                  optionsBuilder: (TextEditingValue value) {
                    final String q = value.text.trim().toLowerCase();
                    if (q.length < 2) return const Iterable<String>.empty();
                    return SampleWeather.cityNames
                        .where((String c) => c.toLowerCase().contains(q))
                        .take(6);
                  },
                  onSelected: (String value) {
                    setState(() => _name.text = value);
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController controller,
                        FocusNode focusNode,
                        VoidCallback onSubmitted,
                      ) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Название',
                            hintText: 'Начните вводить',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                          validator: (String? v) {
                            final String t = (v ?? '').trim();
                            if (t.isEmpty) {
                              return 'Введите название города';
                            }
                            if (t.length < 2) {
                              return 'Слишком короткое название';
                            }
                            return null;
                          },
                          onChanged: (String v) {
                            if (v != _name.text) {
                              _name.text = v;
                              _name.selection = TextSelection.collapsed(
                                offset: v.length,
                              );
                            }
                          },
                        );
                      },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _nickname,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Отображаемое имя',
                    hintText: 'Необязательно',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (String? v) {
                    if ((v ?? '').trim().length > 24) {
                      return 'Не больше 24 символов';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  initialValue: _country,
                  decoration: const InputDecoration(
                    labelText: 'Страна',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: <DropdownMenuItem<String>>[
                    for (final String c in countries)
                      DropdownMenuItem<String>(value: c, child: Text(c)),
                  ],
                  onChanged: (String? v) =>
                      setState(() => _country = v ?? _country),
                ),
                const SizedBox(height: 6),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isMain,
                  onChanged: (bool v) => setState(() => _isMain = v),
                  title: const Text('Сделать текущим'),
                  subtitle: const Text('Открывать приложение с этим городом'),
                ),
                const SizedBox(height: 10),

                FilledButton(
                  onPressed: _submit,
                  child: const Text('Добавить город'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
