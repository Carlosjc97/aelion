import 'package:flutter/material.dart';
import 'package:learning_ia/core/app_colors.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/features/topics/topic_search_view.dart';

class HomeView extends StatelessWidget {
  static const routeName = '/';

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Aelion')),
      body: Container(color: Colors.blue),
    );
  }
}

class _CtaCard extends StatelessWidget {
  final String title;
  final String emoji;
  final VoidCallback onTap;

  const _CtaCard.primary({
    required this.title,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.neutral),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.onSurface),
          ],
        ),
      ),
    );
  }
}
