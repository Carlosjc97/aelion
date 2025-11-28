import 'package:flutter/material.dart';
import 'package:edaptia/core/app_colors.dart';

class EdaptiaAppBar extends AppBar {
  EdaptiaAppBar({super.key, String title = 'Edaptia'})
      : super(
          title: Text(title),
          backgroundColor: AppColors.primary,
          elevation: 0,
        );
}

