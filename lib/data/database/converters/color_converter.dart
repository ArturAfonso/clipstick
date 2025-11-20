import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

/// 🎨 CONVERSOR DE COR PARA DRIFT
/// 
/// Converte objetos Color do Flutter para inteiros (int) armazenáveis no SQLite.
/// 
/// **Como funciona:**
/// - Color → int: Usa `color.value` (ex: Colors.red = 0xFFFF0000)
/// - int → Color: Reconstroi usando `Color(intValue)`
/// 
/// **Exemplo de uso na tabela:**
/// ```dart
/// IntColumn get colorValue => integer().map(const ColorConverter())();
/// ```
class ColorConverter extends TypeConverter<Color, int> {
  const ColorConverter();

  /// ✅ CONVERTE Color → int (para salvar no banco)
  /// 
  /// Exemplo: Color(0xFFFF5733) → 4294934323
  @override
  int toSql(Color value) {
    return value.value;
  }

  /// ✅ CONVERTE int → Color (ao ler do banco)
  /// 
  /// Exemplo: 4294934323 → Color(0xFFFF5733)
  @override
  Color fromSql(int fromDb) {
    return Color(fromDb);
  }
}