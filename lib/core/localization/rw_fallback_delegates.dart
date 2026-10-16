import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Flutter ships no Material/Cupertino localizations for Kinyarwanda ('rw').
/// Without these delegates, selecting 'rw' leaves widgets such as TextField and
/// date pickers without MaterialLocalizations and they throw at runtime.
/// App text is translated by LocalizationService; these only supply the
/// framework's own strings (copy/paste, dialog buttons, ...) in English.
class RwFallbackLocalizations {
  static const List<LocalizationsDelegate<dynamic>> delegates = [
    _RwMaterialDelegate(),
    _RwCupertinoDelegate(),
  ];
}

class _RwMaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _RwMaterialDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) =>
      false;
}

class _RwCupertinoDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _RwCupertinoDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<CupertinoLocalizations> old) =>
      false;
}
