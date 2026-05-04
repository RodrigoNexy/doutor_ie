import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'stripe_colors.dart';

abstract final class AppTheme {
  static final List<FontFeature> ss01 = [FontFeature.stylisticSet(1)];

  static ThemeData light() {
    final baseText = GoogleFonts.interTextTheme().apply(
      bodyColor: StripeColors.body,
      displayColor: StripeColors.heading,
    );

    final textTheme = baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(
        fontWeight: FontWeight.w300,
        letterSpacing: -1.4,
        color: StripeColors.heading,
        fontFeatures: ss01,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        fontWeight: FontWeight.w300,
        letterSpacing: -0.64,
        color: StripeColors.heading,
        fontFeatures: ss01,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontWeight: FontWeight.w300,
        letterSpacing: -0.22,
        color: StripeColors.heading,
        fontFeatures: ss01,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        fontWeight: FontWeight.w300,
        height: 1.4,
        color: StripeColors.body,
        fontFeatures: ss01,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        fontWeight: FontWeight.w300,
        height: 1.4,
        color: StripeColors.body,
        fontFeatures: ss01,
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        fontWeight: FontWeight.w400,
        color: StripeColors.label,
        fontFeatures: ss01,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: StripeColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: StripeColors.purple,
        brightness: Brightness.light,
        primary: StripeColors.purple,
        onPrimary: StripeColors.surface,
        surface: StripeColors.surface,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: StripeColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StripeColors.surface,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: StripeColors.label,
          fontFeatures: ss01,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: StripeColors.label,
          fontFeatures: ss01,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: StripeColors.body,
          fontFeatures: ss01,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StripeColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StripeColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StripeColors.purple, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StripeColors.errorRuby),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: StripeColors.purple,
          foregroundColor: StripeColors.surface,
          disabledBackgroundColor: StripeColors.border,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFeatures: ss01,
          ),
        ),
      ),
    );
  }
}
