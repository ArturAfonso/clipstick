import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headingMedium => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle bodySmall = TextStyle( // ✅ ADICIONAR
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyLarge = TextStyle( // ✅ ADICIONAR ESTA LINHA
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle get noteTitle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get noteContent => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}
