import 'package:flutter/material.dart';

enum AppThemeOption {
  indigo,
  teal,
  rose,
  amber,
  slate;

  String get label {
    switch (this) {
      case AppThemeOption.indigo: return 'Índigo';
      case AppThemeOption.teal:   return 'Verde azulado';
      case AppThemeOption.rose:   return 'Rosa';
      case AppThemeOption.amber:  return 'Ámbar';
      case AppThemeOption.slate:  return 'Gris';
    }
  }

  Color get seedColor {
    switch (this) {
      case AppThemeOption.indigo: return Colors.indigo;
      case AppThemeOption.teal:   return Colors.teal;
      case AppThemeOption.rose:   return const Color(0xFFE11D48);
      case AppThemeOption.amber:  return Colors.amber;
      case AppThemeOption.slate:  return Colors.blueGrey;
    }
  }

  Icon get icon => Icon(Icons.circle, color: seedColor);
}