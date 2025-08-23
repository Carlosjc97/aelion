import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AelionAppBar extends AppBar {
  AelionAppBar({super.key, String title = 'Aelion'})
    : super(
        title: Text(title),
        backgroundColor: AppColors.primary,
        elevation: 0,
      );
}
