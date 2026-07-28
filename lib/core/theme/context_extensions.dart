import 'package:flutter/material.dart';

import 'app_colors.dart';

extension AppContextX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
