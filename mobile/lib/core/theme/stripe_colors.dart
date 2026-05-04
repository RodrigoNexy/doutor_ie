import 'package:flutter/material.dart';

abstract final class StripeColors {
  static const Color purple = Color(0xFF533AFD);
  static const Color purpleHover = Color(0xFF4434D4);
  static const Color heading = Color(0xFF061B31);
  static const Color label = Color(0xFF273951);
  static const Color body = Color(0xFF64748D);
  static const Color border = Color(0xFFE5EDF5);
  static const Color borderPurple = Color(0xFFB9B9F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color brandDark = Color(0xFF1C1E54);
  static const Color errorRuby = Color(0xFFEA2261);

  static const List<BoxShadow> cardShadowElevated = [
    BoxShadow(
      color: Color.fromRGBO(50, 50, 93, 0.25),
      offset: Offset(0, 30),
      blurRadius: 45,
      spreadRadius: -30,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      offset: Offset(0, 18),
      blurRadius: 36,
      spreadRadius: -18,
    ),
  ];
}
