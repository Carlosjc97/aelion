import 'package:flutter/material.dart';
import 'package:learning_ia/core/app_colors.dart';
import 'package:learning_ia/features/topics/topic_search_view.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';

class HomeView extends StatelessWidget {
  static const routeName = '/';

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    assert(() {
      debugPrint('BUILD: HomeView');
      return true;
    }());
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Aelion')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 720;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
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

                      const SizedBox(height: 22),

                      // Acciones principales (CTAs)
                      if (isWide)
                        Row(
                          children: [
                            Expanded(
                              child: _CtaCard.primary(
                                title: 'Toma un curso',
                                emoji: '📘',
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    ModuleOutlineView.routeName,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _CtaCard.primary(
                                title: 'Aprende un idioma',
                                emoji: '🌍',
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    TopicSearchView.routeName,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _CtaCard.primary(
                                title: 'Resuelve un problema',
                                emoji: '🧩',
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    TopicSearchView.routeName,
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _CtaCard.primary(
                              title: 'Toma un curso',
                              emoji: '📘',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  ModuleOutlineView.routeName,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _CtaCard.primary(
                              title: 'Aprende un idioma',
                              emoji: '🌍',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  TopicSearchView.routeName,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _CtaCard.primary(
                              title: 'Resuelve un problema',
                              emoji: '🧩',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  TopicSearchView.routeName,
                                );
                              },
                            ),
                          ],
                        ),
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

class _CtaCard extends StatelessWidget {
  final String title;
  final String emoji;
  final VoidCallback onTap;
  final bool isPrimary;

  const _CtaCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.onTap,
    this.isPrimary = false,
  });

  // ✅ La fábrica ahora pasa `key` al constructor principal
  factory _CtaCard.primary({
    Key? key,
    required String title,
    required String emoji,
    required VoidCallback onTap,
  }) {
    return _CtaCard(
      key: key,
      title: title,
      emoji: emoji,
      onTap: onTap,
      isPrimary: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: text.titleMedium,
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
