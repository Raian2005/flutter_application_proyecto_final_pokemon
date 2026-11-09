import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text.dart';

// Colores propios de la Pokédex
@immutable
class PokedexTheme extends ThemeExtension<PokedexTheme> {
  const PokedexTheme({
    required this.background,
    required this.surfaceMuted,
    required this.inkMuted,
    required this.outline,
    required this.online,
    required this.offline,
    required this.unavailable,
    required this.syncing,
  });

  final Color background;
  final Color surfaceMuted;
  final Color inkMuted;
  final Color outline;
  final Color online;
  final Color offline;
  final Color unavailable;
  final Color syncing;

  static PokedexTheme of(BuildContext context) =>
      Theme.of(context).extension<PokedexTheme>()!;

  @override
  PokedexTheme copyWith({
    Color? background,
    Color? surfaceMuted,
    Color? inkMuted,
    Color? outline,
    Color? online,
    Color? offline,
    Color? unavailable,
    Color? syncing,
  }) {
    return PokedexTheme(
      background: background ?? this.background,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      inkMuted: inkMuted ?? this.inkMuted,
      outline: outline ?? this.outline,
      online: online ?? this.online,
      offline: offline ?? this.offline,
      unavailable: unavailable ?? this.unavailable,
      syncing: syncing ?? this.syncing,
    );
  }

  @override
  PokedexTheme lerp(ThemeExtension<PokedexTheme>? other, double t) {
    if (other is! PokedexTheme) return this;
    return PokedexTheme(
      background: Color.lerp(background, other.background, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      online: Color.lerp(online, other.online, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
      unavailable: Color.lerp(unavailable, other.unavailable, t)!,
      syncing: Color.lerp(syncing, other.syncing, t)!,
    );
  }
}

/// Temas claro y oscuro
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceMuted =
        isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final inkMuted = isDark ? AppColors.darkInkMuted : AppColors.lightInkMuted;
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final primary = isDark ? AppColors.brandOnDark : AppColors.brand;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      onPrimary: isDark ? const Color(0xFF1C0603) : Colors.white,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: inkMuted,
      outline: outline,
      outlineVariant: outline,
      surfaceContainerHighest: surfaceMuted,
      error: AppColors.danger,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
    );
    final textTheme = AppText.textTheme(base.textTheme, ink);

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.field),
      borderSide: BorderSide(color: outline),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withValues(alpha: 0.14),
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected) ? ink : inkMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? primary : inkMuted,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: inkMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: ink, width: 1.5),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(kMinTapTarget, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.field),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(kMinTapTarget, 52),
          foregroundColor: ink,
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.field),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: background),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      extensions: [
        PokedexTheme(
          background: background,
          surfaceMuted: surfaceMuted,
          inkMuted: inkMuted,
          outline: outline,
          online: isDark ? AppColors.onlineDark : AppColors.onlineLight,
          offline: isDark ? AppColors.offlineDark : AppColors.offlineLight,
          unavailable:
              isDark ? AppColors.unavailableDark : AppColors.unavailableLight,
          syncing: isDark ? AppColors.syncingDark : AppColors.syncingLight,
        ),
      ],
    );
  }
}
