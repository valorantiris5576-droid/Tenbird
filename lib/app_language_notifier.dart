import 'package:flutter/material.dart';
import 'app_language.dart';
import 'app_language.dart';

class AppLanguageNotifier extends ChangeNotifier {
  static final AppLanguageNotifier instance = AppLanguageNotifier._();
  AppLanguageNotifier._();

  void changeLang(String code) {
    AppLanguage.current = code;
    notifyListeners();
  }
}
