import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:edaptia/features/lesson/lesson_detail_page.dart';
import 'package:edaptia/features/quiz/quiz_screen.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/analytics/analytics_service.dart';
import 'package:edaptia/services/course_api_service.dart';
import 'package:edaptia/services/local_outline_storage.dart';
import 'package:edaptia/services/quiz_attempt_storage.dart';
import 'package:edaptia/services/recent_outlines_storage.dart';
import 'package:edaptia/services/topic_band_cache.dart';
import 'package:edaptia/widgets/skeleton.dart';

part 'module_outline_controller.dart';
part 'module_outline_controller_actions.dart';
part 'widgets/module_card.dart';
part 'widgets/lesson_card.dart';
part 'widgets/module_progress_indicator.dart';
part 'widgets/outline_meta_item.dart';
part 'widgets/outline_skeleton.dart';
part 'widgets/outline_error_view.dart';
part 'widgets/outline_header.dart';
part 'widgets/outline_content.dart';

enum RefineAction { depth, quiz }

class ModuleOutlineArgs {
  const ModuleOutlineArgs({
    required this.topic,
    this.level,
    this.language,
    this.goal,
    this.depth,
    this.preferredBand,
    this.recommendRegenerate,
    this.initialOutline,
    this.initialResponse,
    this.initialSource,
    this.initialSavedAt,
    this.outlineFetcher,
  });

  final String topic;
  final String? level;
  final String? language;
  final String? goal;
  final String? depth;
  final String? preferredBand;
  final bool? recommendRegenerate;
  final List<Map<String, dynamic>>? initialOutline;
  final Map<String, dynamic>? initialResponse;
  final String? initialSource;
  final DateTime? initialSavedAt;
  final OutlineFetcher? outlineFetcher;
}

class ModuleOutlineView extends StatefulWidget {
  static const routeName = '/module';

  const ModuleOutlineView({
    super.key,
    this.topic,
    this.level,
    this.language,
    this.goal,
    this.depth,
    this.preferredBand,
    this.recommendRegenerate,
    this.initialOutline,
    this.initialResponse,
    this.initialSource,
    this.initialSavedAt,
    this.outlineFetcher,
  });

  final String? topic;
  final String? level;
  final String? language;
  final String? goal;
  final String? depth;
  final String? preferredBand;
  final bool? recommendRegenerate;
  final List<Map<String, dynamic>>? initialOutline;
  final Map<String, dynamic>? initialResponse;
  final String? initialSource;
  final DateTime? initialSavedAt;
  final OutlineFetcher? outlineFetcher;

  @override
  State<ModuleOutlineView> createState() => _ModuleOutlineViewState();
}

class _ModuleOutlineViewState extends State<ModuleOutlineView>
    with ModuleOutlineController {}
