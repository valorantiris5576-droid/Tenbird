class AppLanguage {
  static String current = 'en';

  static String t({
    required String en,
    required String ko,
    required String ja,
    required String es,
    required String zh,
  }) {
    switch (current) {
      case 'ko':
        return ko;
      case 'ja':
        return ja;
      case 'es':
        return es;
      case 'zh':
        return zh;
      default:
        return en;
    }
  }
}
