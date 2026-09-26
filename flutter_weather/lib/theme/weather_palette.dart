import 'package:flutter/material.dart';

import '../data/models.dart';

/// Палитра неба под конкретную погоду и время суток.
class WeatherPalette {
  const WeatherPalette({
    required this.colors,
    required this.accent,
    required this.text,
    required this.textMuted,
    required this.glass,
    required this.glassBorder,
    required this.shadow,
  });

  /// Три цвета вертикального градиента неба.
  final List<Color> colors;

  /// Акцентный цвет: кнопки, выделенные элементы.
  final Color accent;
  final Color text;
  final Color textMuted;

  /// Заливка стеклянных карточек.
  final Color glass;
  final Color glassBorder;
  final Color shadow;

  LinearGradient get skyGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: colors,
  );

  /// Подбирает палитру по явлению и времени суток.
  factory WeatherPalette.of(WeatherKind kind, DateTime time) {
    final int hour = time.hour;
    final bool night = hour >= 20 || hour < 6;
    final bool evening = hour >= 17 && hour < 20;

    if (night) {
      return switch (kind) {
        WeatherKind.clear => const WeatherPalette(
          colors: <Color>[
            Color(0xFF0A1130),
            Color(0xFF152356),
            Color(0xFF2B3A75),
          ],
          accent: Color(0xFF8FA6FF),
          text: Colors.white,
          textMuted: Color(0xFFA9B6D8),
          glass: Color(0x14FFFFFF),
          glassBorder: Color(0x24FFFFFF),
          shadow: Color(0x40000000),
        ),
        WeatherKind.partlyCloudy || WeatherKind.cloudy => const WeatherPalette(
          colors: <Color>[
            Color(0xFF141C3B),
            Color(0xFF26325C),
            Color(0xFF41507E),
          ],
          accent: Color(0xFF9FB4E8),
          text: Colors.white,
          textMuted: Color(0xFFA6B2D2),
          glass: Color(0x12FFFFFF),
          glassBorder: Color(0x1FFFFFFF),
          shadow: Color(0x33000000),
        ),
        WeatherKind.rain || WeatherKind.thunder => const WeatherPalette(
          colors: <Color>[
            Color(0xFF0D1520),
            Color(0xFF1E2A3C),
            Color(0xFF33445C),
          ],
          accent: Color(0xFF7FA6D8),
          text: Colors.white,
          textMuted: Color(0xFF9FAEC4),
          glass: Color(0x0FFFFFFF),
          glassBorder: Color(0x1AFFFFFF),
          shadow: Color(0x33000000),
        ),
        _ => const WeatherPalette(
          colors: <Color>[
            Color(0xFF1B2340),
            Color(0xFF2E3A5E),
            Color(0xFF4A5980),
          ],
          accent: Color(0xFFA9BBE8),
          text: Colors.white,
          textMuted: Color(0xFFA6B2D2),
          glass: Color(0x12FFFFFF),
          glassBorder: Color(0x1FFFFFFF),
          shadow: Color(0x33000000),
        ),
      };
    }

    if (evening && kind != WeatherKind.rain && kind != WeatherKind.thunder) {
      return const WeatherPalette(
        colors: <Color>[
          Color(0xFF3A2C6B),
          Color(0xFFB4527E),
          Color(0xFFFF8E53),
        ],
        accent: Color(0xFFFFD39B),
        text: Colors.white,
        textMuted: Color(0xFFFBD8C6),
        glass: Color(0x1AFFFFFF),
        glassBorder: Color(0x33FFFFFF),
        shadow: Color(0x40000000),
      );
    }

    return switch (kind) {
      WeatherKind.clear => const WeatherPalette(
        colors: <Color>[
          Color(0xFF1D6FE0),
          Color(0xFF3E9BF0),
          Color(0xFF7FC7F5),
        ],
        accent: Color(0xFFFFFFFF),
        text: Colors.white,
        textMuted: Color(0xFFDCEEFF),
        glass: Color(0x1FFFFFFF),
        glassBorder: Color(0x3DFFFFFF),
        shadow: Color(0x2E0B3D6B),
      ),
      WeatherKind.partlyCloudy => const WeatherPalette(
        colors: <Color>[
          Color(0xFF2160B8),
          Color(0xFF4A93E0),
          Color(0xFF8FC4F0),
        ],
        accent: Colors.white,
        text: Colors.white,
        textMuted: Color(0xFFDDECFB),
        glass: Color(0x1FFFFFFF),
        glassBorder: Color(0x33FFFFFF),
        shadow: Color(0x2E0B3D6B),
      ),
      WeatherKind.cloudy => const WeatherPalette(
        colors: <Color>[
          Color(0xFF4A5A70),
          Color(0xFF71829A),
          Color(0xFF9FAEC1),
        ],
        accent: Colors.white,
        text: Colors.white,
        textMuted: Color(0xFFE3E9F0),
        glass: Color(0x1AFFFFFF),
        glassBorder: Color(0x2EFFFFFF),
        shadow: Color(0x33202A38),
      ),
      WeatherKind.rain => const WeatherPalette(
        colors: <Color>[
          Color(0xFF2C3E55),
          Color(0xFF486A88),
          Color(0xFF6D93B0),
        ],
        accent: Color(0xFFBFE3FF),
        text: Colors.white,
        textMuted: Color(0xFFCEDDE9),
        glass: Color(0x14FFFFFF),
        glassBorder: Color(0x2BFFFFFF),
        shadow: Color(0x3D16222E),
      ),
      WeatherKind.thunder => const WeatherPalette(
        colors: <Color>[
          Color(0xFF1A2138),
          Color(0xFF333E5C),
          Color(0xFF515F85),
        ],
        accent: Color(0xFFFFD66B),
        text: Colors.white,
        textMuted: Color(0xFFC7CCE0),
        glass: Color(0x12FFFFFF),
        glassBorder: Color(0x26FFFFFF),
        shadow: Color(0x40000000),
      ),
      WeatherKind.snow => const WeatherPalette(
        colors: <Color>[
          Color(0xFF5A7392),
          Color(0xFF87A2C0),
          Color(0xFFBCD3E8),
        ],
        accent: Colors.white,
        text: Colors.white,
        textMuted: Color(0xFFEAF2FA),
        glass: Color(0x1AFFFFFF),
        glassBorder: Color(0x33FFFFFF),
        shadow: Color(0x2E3A5570),
      ),
      WeatherKind.fog => const WeatherPalette(
        colors: <Color>[
          Color(0xFF63707E),
          Color(0xFF8B97A4),
          Color(0xFFB4BDC7),
        ],
        accent: Colors.white,
        text: Colors.white,
        textMuted: Color(0xFFE8ECF0),
        glass: Color(0x18FFFFFF),
        glassBorder: Color(0x2EFFFFFF),
        shadow: Color(0x33263038),
      ),
    };
  }
}
