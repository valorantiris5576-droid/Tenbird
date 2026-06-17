import 'package:flutter_test/flutter_test.dart';

import 'package:run_donate/theme/app_colors.dart';

void main() {
  test('StepGive brand colors are defined', () {
    expect(AppColors.background.value, 0xFF0A0E1A);
    expect(AppColors.accent.value, 0xFF00C896);
  });
}
