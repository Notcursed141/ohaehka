import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models.dart';
import 'weather_icons.dart';

/// График почасовой температуры.
///
/// Кривая рисуется вручную: точки соединяются плавными кубическими
/// кривыми, под линией — градиентная заливка. График и подписи часов
/// лежат в одном горизонтальном скролле, поэтому подписи всегда
/// остаются точно под своими точками.
class HourlyChart extends StatefulWidget {
  const HourlyChart({
    super.key,
    required this.hourly,
    required this.unit,
    required this.night,
    this.chartHeight = 158,
  });

  final List<HourlyPoint> hourly;
  final TempUnit unit;
  final bool night;
  final double chartHeight;

  @override
  State<HourlyChart> createState() => _HourlyChartState();
}

class _HourlyChartState extends State<HourlyChart> {
  /// Шаг между соседними точками. Вдвое больше отступа слева, поэтому
  /// подписи в [_HourlyChartState._labels] совпадают с точками по X.
  static const double _step = 76;

  /// Отступ слева под служебные подписи «мин» и «макс».
  static const double _left = _step / 2;

  static const double _padTop = 36;
  static const double _padBottom = 12;

  final ScrollController _scroll = ScrollController();
  int _active = 0;

  double get _contentWidth => widget.hourly.length * _step;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(HourlyChart old) {
    super.didUpdateWidget(old);
    if (old.hourly != widget.hourly) {
      _active = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(0);
      });
    }
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients || widget.hourly.isEmpty) return;
    final int index = (_scroll.offset / _step).round().clamp(
      0,
      widget.hourly.length - 1,
    );
    if (index != _active) setState(() => _active = index);
  }

  void _goTo(int index) {
    if (!_scroll.hasClients) return;
    final double max = _scroll.position.maxScrollExtent;
    _scroll.animateTo(
      (index * _step).clamp(0.0, max),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _labels() {
    return Row(
      children: <Widget>[
        for (final HourlyPoint point in widget.hourly)
          SizedBox(
            width: _step,
            child: GestureDetector(
              onTap: () => _goTo(widget.hourly.indexOf(point)),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  WeatherGlyph(kind: point.kind, size: 24, night: widget.night),
                  const SizedBox(height: 3),
                  Text(
                    point.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hourly.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: _contentWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: widget.chartHeight,
              child: CustomPaint(
                painter: _ChartPainter(
                  hourly: widget.hourly,
                  unit: widget.unit,
                  active: _active,
                  night: widget.night,
                ),
              ),
            ),
            const SizedBox(height: 6),
            _labels(),
          ],
        ),
      ),
    );
  }
}

/// Painter кривой температуры.
class _ChartPainter extends CustomPainter {
  const _ChartPainter({
    required this.hourly,
    required this.unit,
    required this.active,
    required this.night,
  });

  final List<HourlyPoint> hourly;
  final TempUnit unit;
  final int active;
  final bool night;

  @override
  void paint(Canvas canvas, Size size) {
    if (hourly.isEmpty) return;

    final List<double> temps = <double>[
      for (final HourlyPoint h in hourly) unit.of(h.temp).toDouble(),
    ];
    final double minT = temps.reduce(math.min);
    final double maxT = temps.reduce(math.max);
    final double span = (maxT - minT).abs() < 1 ? 1.0 : maxT - minT;

    final double usableH =
        size.height - _HourlyChartState._padTop - _HourlyChartState._padBottom;

    double yOf(double t) =>
        _HourlyChartState._padTop + usableH * (1 - (t - minT) / span);

    final List<Offset> points = <Offset>[
      for (int i = 0; i < temps.length; i++)
        Offset(
          _HourlyChartState._left + i * _HourlyChartState._step,
          yOf(temps[i]),
        ),
    ];

    // Сетка с подписями минимума и максимума.
    final Paint grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.13)
      ..strokeWidth = 1;
    for (final double t in <double>[maxT, minT]) {
      final double y = yOf(t);
      canvas.drawLine(
        Offset(_HourlyChartState._left - 26, y),
        Offset(size.width, y),
        grid,
      );
      _text(
        canvas,
        '${t.round()}°',
        Offset(0, y - 7),
        fontSize: 11,
        weight: FontWeight.w600,
        alpha: 0.6,
      );
    }

    final Path line = _smooth(points);
    final Path fill = Path.from(line)
      ..lineTo(points.last.dx, size.height - _HourlyChartState._padBottom)
      ..lineTo(points.first.dx, size.height - _HourlyChartState._padBottom)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.30),
            Colors.white.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = const LinearGradient(
          colors: <Color>[
            Color(0xFFFFFFFF),
            Color(0xFFE6F2FF),
            Color(0xFF9FD2FF),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    for (int i = 0; i < points.length; i++) {
      final bool isActive = i == active;

      if (isActive) {
        canvas.drawCircle(
          points[i],
          14,
          Paint()..color = Colors.white.withValues(alpha: 0.22),
        );
        canvas.drawCircle(points[i], 8.5, Paint()..color = Colors.white);
        canvas.drawCircle(
          points[i],
          3.5,
          Paint()..color = const Color(0xFF2F6FD0),
        );
      } else {
        canvas.drawCircle(
          points[i],
          4.5,
          Paint()..color = Colors.white.withValues(alpha: 0.9),
        );
      }

      _text(
        canvas,
        '${unit.of(hourly[i].temp)}°',
        Offset(points[i].dx - 16, points[i].dy - 32),
        fontSize: isActive ? 13.5 : 12,
        weight: isActive ? FontWeight.w700 : FontWeight.w600,
        alpha: isActive ? 1 : 0.78,
      );
    }
  }

  /// Плавная кривая: контрольные точки ставятся по середине между
  /// соседними, поэтому изгиб получается мягким, без перелётов.
  static Path _smooth(List<Offset> pts) {
    final Path path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final Offset a = pts[i];
      final Offset b = pts[i + 1];
      final double cx = (a.dx + b.dx) / 2;
      path.cubicTo(cx, a.dy, cx, b.dy, b.dx, b.dy);
    }
    return path;
  }

  void _text(
    Canvas canvas,
    String text,
    Offset pos, {
    double fontSize = 12,
    FontWeight weight = FontWeight.w600,
    double alpha = 1,
  }) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: Colors.white.withValues(alpha: alpha),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.active != active || old.hourly != hourly || old.unit != unit;
}

/// Дуга восхода и захода солнца.
class SunPath extends StatelessWidget {
  const SunPath({super.key, required this.progress, this.height = 90});

  /// 0 — до рассвета, 0.5 — полдень, 1 — после заката.
  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SunPathPainter(progress: progress),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SunPathPainter extends CustomPainter {
  const _SunPathPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Дуга рисуется в квадратном прямоугольнике, нижняя половина
    // которого обрезается, — так получается полуокружность.
    final Rect arcRect = Rect.fromLTRB(w * 0.05, h * 0.14, w * 0.95, h * 1.72);
    final double start = math.pi;
    final double sweep = math.pi * progress.clamp(0.0, 1.0);

    canvas.drawPath(
      Path()..addArc(arcRect, start, -math.pi),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.22),
    );

    if (sweep > 0) {
      canvas.drawPath(
        Path()..addArc(arcRect, start, -sweep),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFD66B),
      );
    }

    final double angle = start - sweep;
    final Offset pos = Offset(
      arcRect.center.dx + (arcRect.width / 2) * math.cos(angle),
      arcRect.center.dy + (arcRect.height / 2) * math.sin(angle),
    );

    canvas.drawCircle(
      pos,
      17,
      Paint()..color = const Color(0xFFFFD66B).withValues(alpha: 0.26),
    );
    canvas.drawCircle(pos, 9.5, Paint()..color = const Color(0xFFFFE082));
    canvas.drawCircle(
      pos,
      4,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(_SunPathPainter old) => old.progress != progress;
}
