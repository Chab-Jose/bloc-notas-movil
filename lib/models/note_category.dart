import 'package:flutter/material.dart';

enum NoteCategory {
  purple,
  red,
  blue,
  green,
  yellow;

  Color get color {
    switch (this) {
      case NoteCategory.purple: return const Color(0xFF7C3AED);
      case NoteCategory.red:    return const Color(0xFFDC2626);
      case NoteCategory.blue:   return const Color(0xFF2563EB);
      case NoteCategory.green:  return const Color(0xFF16A34A);
      case NoteCategory.yellow: return const Color(0xFFCA8A04);
    }
  }

  Color get lightColor {
    switch (this) {
      case NoteCategory.purple: return const Color(0xFFEDE9FE);
      case NoteCategory.red:    return const Color(0xFFFEE2E2);
      case NoteCategory.blue:   return const Color(0xFFDBEAFE);
      case NoteCategory.green:  return const Color(0xFFDCFCE7);
      case NoteCategory.yellow: return const Color(0xFFFEF9C3);
    }
  }

  String get label {
    switch (this) {
      case NoteCategory.purple: return 'Morado';
      case NoteCategory.red:    return 'Rojo';
      case NoteCategory.blue:   return 'Azul';
      case NoteCategory.green:  return 'Verde';
      case NoteCategory.yellow: return 'Amarillo';
    }
  }

  static NoteCategory fromString(String value) {
    return NoteCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NoteCategory.purple,
    );
  }
}