import 'package:flutter/material.dart';
import 'package:learning_ia/core/app_colors.dart';

class HomeView extends StatelessWidget {
  static const routeName = '/';

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme; // Re-introduce this

    return Scaffold(
      appBar: AppBar(title: const Text('Aelion')),
      body: SafeArea(
        child: LayoutBuilder( // Keep the structure
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header - This is the only part I'm restoring inside the Column
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('✨', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aelion',
                                    style: text.headlineLarge?.copyWith(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Aprende en minutos',
                                    style: text.bodyLarge?.copyWith(
                                      color: const Color(0xFF5A6B80),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // The rest of the children are omitted for this step
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
