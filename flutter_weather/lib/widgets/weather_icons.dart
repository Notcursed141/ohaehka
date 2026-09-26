import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models.dart';

/// Иконка погоды, нарисованная вручную через [CustomPainter].
///
/// Стандартные иконки Material здесь не подходят: они плоские и не
/// сочетаются с градиентным небом. Собственный painter даёт объёмные
/// градиентные формы и возможность точно попасть в палитру экрана.
class WeatherGlyph extends StatelessWidget {
  const WeatherGlyph({
    super.key,
    required this.kind,
    this.size = 64,
    this.night = false,
  });

  final WeatherKind kind;
  final double size;
  final bool night;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GlyphPainter(kind: kind, night: night),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({required this.kind, required this.night});

  final WeatherKind kind;
  final bool night;

  // Палитра иконок.
  static const Color _sunLight = Color(0xFFFFE9A8);
  static const Color _sunDeep = Color(0xFFFFA726);
  static const Color _moonLight = Color(0xFFFFF8E1);
  static const Color _moonDeep = Color(0xFFFFD666);
  static const Color _cloudLight = Color(0xFFFFFFFF);
  static const Color _cloudMid = Color(0xFFE8EFF7);
  static const Color _cloudDark = Color(0xFFB8C7D9);
  static const Color _rain = Color(0xFF5FC8F5);
  static const Color _bolt = Color(0xFFFFD54F);
  static const Color _snow = Color(0xFFE1F5FE);
  static const Color _fog = Color(0xFFD5DEE8);

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;
    final Offset c = Offset(size.width / 2, size.height / 2);

    switch (kind) {
      case WeatherKind.clear:
        if (night) {
          _paintMoon(canvas, c, s * 0.30);
          _paintStars(canvas, size, s);
        } else {
          _paintSun(canvas, c, s * 0.24);
        }

      case WeatherKind.partlyCloudy:
        _paintSun(canvas, Offset(c.dx + s * 0.16, c.dy - s * 0.20), s * 0.17);
        _paintCloud(
          canvas,
          Rect.fromCenter(
            center: Offset(c.dx - s * 0.05, c.dy + s * 0.10),
            width: s * 0.68,
            height: s * 0.40,
          ),
        );

      case WeatherKind.cloudy:
        _paintCloud(
          canvas,
          Rect.fromCenter(
            center: Offset(c.dx + s * 0.10, c.dy - s * 0.14),
            width: s * 0.50,
            height: s * 0.30,
          ),
          shade: true,
        );
        _paintCloud(
          canvas,
          Rect.fromCenter(
            center: Offset(c.dx - s * 0.04, c.dy + s * 0.10),
            width: s * 0.70,
            height: s * 0.42,
          ),
        );

      case WeatherKind.rain:
        _paintCloud(
          canvas,
          Rect.fromCenter(
            center: c + Offset(0, -s * 0.12),
            width: s * 0.70,
            height: s * 0.42,
          ),
        );
        _paintRain(canvas, size, s);

      case WeatherKind.thunder:
        _paintCloud(
          canvas,
          Rect.fromCenter(
            center: c + Offset(0, -s * 0.14),
            width: s * 0.70,
            height: s * 0.42,
          ),
          shade: true,
        );
        _paintBolt(canvas, Offset(c.dx, c.dy + s * 0.26), s * 0.16);
        _paintRain(canvas, size, s * 0.8, drops: 2);

      case WeatherKind.snow:
        _paintCloud(
          canvas,
          Rect.fromCenter(
            center: c + Offset(0, -s * 0.12),
            width: s * 0.70,
            height: s * 0.42,
          ),
        );
        _paintSnow(canvas, size, s);

      case WeatherKind.fog:
        _paintCloud(
          canvas,
          Rect.fromCenter(
            center: c + Offset(0, -s * 0.14),
            width: s * 0.70,
            height: s * 0.40,
          ),
          shade: true,
        );
        _paintFog(canvas, size, s);
    }
  }

  // --- Отдельные элементы -------------------------------------------

  void _paintSun(Canvas canvas, Offset c, double r) {
    final Paint ray = Paint()
      ..color = _sunDeep.withValues(alpha: 0.55)
      ..strokeWidth = r * 0.20
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final double a = i * math.pi / 4 + math.pi / 8;
      final Offset dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + dir * (r * 1.35), c + dir * (r * 1.85), ray);
    }

    final Paint disc = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: <Color>[_sunLight, _sunDeep],
      ).createShader(Rect.fromCircle(center: c, radius: r));

    canvas.drawCircle(c, r, disc);
  }

  void _paintMoon(Canvas canvas, Offset c, double r) {
    final Path moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      Path()..addOval(
        Rect.fromCircle(
          center: c + Offset(r * 0.50, -r * 0.34),
          radius: r * 0.92,
        ),
      ),
    );

    final Paint fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[_moonLight, _moonDeep],
      ).createShader(Rect.fromCircle(center: c, radius: r));

    canvas.drawPath(moon, fill);
  }

  void _paintStars(Canvas canvas, Size size, double s) {
    final Paint paint = Paint()..color = _moonLight.withValues(alpha: 0.85);
    const List<Offset> spots = <Offset>[
      Offset(0.14, 0.18),
      Offset(0.30, 0.09),
      Offset(0.09, 0.36),
    ];
    for (final Offset o in spots) {
      canvas.drawCircle(Offset(o.dx * s, o.dy * s), s * 0.022, paint);
    }
  }

  /// Облако собирается из нескольких овалов и прямоугольника в один Path.
  /// При заливке nonZero пересекающиеся части сливаются в целое.
  void _paintCloud(Canvas canvas, Rect r, {bool shade = false}) {
    final Path path = Path()..fillType = PathFillType.nonZero;

    path.addOval(
      Rect.fromCircle(
        center: Offset(r.left + r.width * 0.30, r.top + r.height * 0.46),
        radius: r.height * 0.30,
      ),
    );
    path.addOval(
      Rect.fromCircle(
        center: Offset(r.left + r.width * 0.48, r.top + r.height * 0.28),
        radius: r.height * 0.36,
      ),
    );
    path.addOval(
      Rect.fromCircle(
        center: Offset(r.left + r.width * 0.70, r.top + r.height * 0.48),
        radius: r.height * 0.26,
      ),
    );
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          r.left,
          r.top + r.height * 0.46,
          r.width,
          r.height * 0.30,
        ),
        Radius.circular(r.height * 0.15),
      ),
    );

    final Paint fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: shade
            ? <Color>[_cloudMid, _cloudDark]
            : <Color>[_cloudLight, _cloudMid],
      ).createShader(r);

    canvas.drawPath(path, fill);
  }

  void _paintRain(Canvas canvas, Size size, double s, {int drops = 3}) {
    final Paint paint = Paint()
      ..color = _rain
      ..strokeWidth = s * 0.045
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < drops; i++) {
      final double x = s * (0.34 + i * 0.16);
      canvas.drawLine(
        Offset(x, s * 0.68),
        Offset(x - s * 0.06, s * 0.84),
        paint,
      );
    }
  }

  void _paintBolt(Canvas canvas, Offset c, double r) {
    final Path bolt = Path()
      ..moveTo(c.dx + r * 0.25, c.dy - r)
      ..lineTo(c.dx - r * 0.55, c.dy + r * 0.12)
      ..lineTo(c.dx + r * 0.02, c.dy + r * 0.12)
      ..lineTo(c.dx - r * 0.25, c.dy + r)
      ..lineTo(c.dx + r * 0.58, c.dy - r * 0.14)
      ..lineTo(c.dx + r * 0.02, c.dy - r * 0.14)
      ..close();

    canvas.drawPath(
      bolt,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[_bolt, const Color(0xFFFFA000)],
        ).createShader(Rect.fromCircle(center: c, radius: r * 1.2)),
    );
  }

  void _paintSnow(Canvas canvas, Size size, double s) {
    final Paint paint = Paint()
      ..color = _snow
      ..strokeWidth = s * 0.028
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final Offset c = Offset(s * (0.36 + i * 0.16), s * 0.78);
      for (int k = 0; k < 3; k++) {
        final double a = k * math.pi / 3;
        final Offset d = Offset(math.cos(a), math.sin(a)) * s * 0.075;
        canvas.drawLine(c - d, c + d, paint);
      }
    }
  }

  void _paintFog(Canvas canvas, Size size, double s) {
    final Paint paint = Paint()
      ..color = _fog
      ..strokeWidth = s * 0.05
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final double y = s * (0.66 + i * 0.11);
      final double inset = i.isEven ? s * 0.24 : s * 0.32;
      canvas.drawLine(Offset(inset, y), Offset(s - inset, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.kind != kind || old.night != night;
}

/// Стрелка направления ветра с названием румба.
class WindArrow extends StatelessWidget {
  const WindArrow({super.key, required this.degrees, this.size = 18});

  final int degrees;
  final double size;

  static const List<String> _points = <String>[
    'С',
    'ССВ',
    'СВ',
    'ВСВ',
    'В',
    'ВЮВ',
    'ЮВ',
    'ЮЮВ',
    'Ю',
    'ЮЮЗ',
    'ЮЗ',
    'ЗЮЗ',
    'З',
    'ЗСЗ',
    'СЗ',
    'ССЗ',
  ];

  String get title => _points[(degrees ~/ 22.5) % 16];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Transform.rotate(
          angle: degrees * math.pi / 180,
          child: Icon(
            Icons.navigation_rounded,
            size: size,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: size * 0.62,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
