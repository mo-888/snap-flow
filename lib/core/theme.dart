import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SnapFlow design tokens — matches ui/index.html prototype.
class SnapFlowTheme {
  // Brand palette
  static const Color primary = Color(0xFF0D9488);
  static const Color secondary = Color(0xFF14B8A6);
  static const Color accent = Color(0xFFEA580C);
  static const Color destructive = Color(0xFFDC2626);

  static const Color _bgLight = Color(0xFFF0FDFA);
  static const Color _fgLight = Color(0xFF134E4A);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surface2Light = Color(0xFFECFDF5);
  static const Color _mutedLight = Color(0xFFE8F1F4);
  static const Color _borderLight = Color(0xFF99F6E4);

  static const Color _bgDark = Color(0xFF0B1F1D);
  static const Color _fgDark = Color(0xFFE6FFFA);
  static const Color _surfaceDark = Color(0xFF0F2A28);
  static const Color _surface2Dark = Color(0xFF103B38);
  static const Color _mutedDark = Color(0xFF134E4A);
  static const Color _borderDark = Color(0xFF0F766E);

  static TextTheme _textTheme(Color onSurface) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      bodyLarge: base.bodyLarge?.copyWith(color: onSurface),
      bodyMedium: base.bodyMedium?.copyWith(color: onSurface),
      titleLarge: base.titleLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w800),
      titleMedium: base.titleMedium?.copyWith(color: onSurface, fontWeight: FontWeight.w700),
      labelLarge: base.labelLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
    );
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      surface: _surface,
      error: destructive,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _bgLight,
      textTheme: _textTheme(_fgLight),
      appBarTheme: AppBarTheme(
        backgroundColor: _bgLight,
        foregroundColor: _fgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: _fgLight,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      extensions: const [
        SnapFlowColors(
          surface2: _surface2Light,
          muted: _mutedLight,
          border: _borderLight,
        ),
      ],
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      surface: _surfaceDark,
      error: destructive,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _bgDark,
      textTheme: _textTheme(_fgDark),
      appBarTheme: AppBarTheme(
        backgroundColor: _bgDark,
        foregroundColor: _fgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: _fgDark,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      extensions: const [
        SnapFlowColors(
          surface2: _surface2Dark,
          muted: _mutedDark,
          border: _borderDark,
        ),
      ],
    );
  }
}

/// Extra design tokens not in ColorScheme.
class SnapFlowColors extends ThemeExtension<SnapFlowColors> {
  final Color surface2;
  final Color muted;
  final Color border;

  const SnapFlowColors({
    required this.surface2,
    required this.muted,
    required this.border,
  });

  @override
  SnapFlowColors copyWith({Color? surface2, Color? muted, Color? border}) =>
      SnapFlowColors(
        surface2: surface2 ?? this.surface2,
        muted: muted ?? this.muted,
        border: border ?? this.border,
      );

  @override
  SnapFlowColors lerp(ThemeExtension<SnapFlowColors>? other, double t) {
    if (other is! SnapFlowColors) return this;
    return SnapFlowColors(
      surface2: Color.lerp(surface2, other.surface2, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

extension SnapFlowColorsAccess on BuildContext {
  SnapFlowColors get sf => Theme.of(this).extension<SnapFlowColors>()!;
}
