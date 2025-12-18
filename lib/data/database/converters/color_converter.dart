// ignore_for_file: deprecated_member_use

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';


class ColorConverter extends TypeConverter<Color, int> {
  const ColorConverter();

  @override
  int toSql(Color value) {
    return value.value;
  }

  @override
  Color fromSql(int fromDb) {
    return Color(fromDb);
  }
}