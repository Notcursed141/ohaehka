import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/weather_palette.dart';

/// Каркас экрана с градиентным небом.
///
/// Палитра подбирается автоматически по погоде и времени суток,
/// поэтому ночью градиент становится тёмно-синим, а вечером —
/// закатным. Все экраны погоды строятся поверх этого виджета.
class WeatherScaffold extends StatelessWidget {
  const WeatherScaffold({
    super.key,
    required this.kind,
    required this.time,
    required this.body,
    this.appBar,
    this.bottomBar,
    this.floatingActionButton,
  });

  final WeatherKind kind;
  final DateTime time;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomBar;
  final Widget? floatingActionButton;

  /// Палитра текущего экрана — чтобы содержимое знало свои цвета.
  static WeatherPalette paletteOf(BuildContext context) {
    final _WeatherScope? scope = context
        .dependOnInheritedWidgetOfExactType<_WeatherScope>();
    return scope?.palette ??
        WeatherPalette.of(WeatherKind.clear, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final WeatherPalette palette = WeatherPalette.of(kind, time);

    return _WeatherScope(
      palette: palette,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: palette.colors.last,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomBar,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: palette.colors,
              stops: const <double>[0, 0.55, 1],
            ),
          ),
          child: SafeArea(bottom: false, child: body),
        ),
      ),
    );
  }
}

/// Передаёт палитру вниз по дереву.
class _WeatherScope extends InheritedWidget {
  const _WeatherScope({required this.palette, required super.child});

  final WeatherPalette palette;

  @override
  bool updateShouldNotify(_WeatherScope old) => old.palette != palette;
}

/// Круглая полупрозрачная кнопка поверх неба.
class SkyButton extends StatelessWidget {
  const SkyButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 21, color: Colors.white),
        ),
      ),
    );
  }
}

/// Показывает SnackBar в едином стиле.
void showSkySnackBar(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle_outline_rounded,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
