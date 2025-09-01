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
            final isWide = constraints.maxWidth >= 840;

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
                                      color: Color(0xFF5A6B80),
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

                      // Search Card
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'Buscar un tema',
                                      prefixIcon: Icon(Icons.search_rounded),
                                    ),
                                    onSubmitted: (_) {
                                      Navigator.pushNamed(
                                        context,
                                        TopicSearchView.routeName,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                FilledButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      TopicSearchView.routeName,
                                    );
                                  },
                                  icon: const Icon(Icons.search),
                                  label: const Text('Buscar'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ActionChip(
                                  avatar: const Text('🔎'),
                                  label: const Text('Buscar un tema'),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      TopicSearchView.routeName,
                                    );
                                  },
                                ),
                                ActionChip(
                                  avatar: const Text('📌'),
                                  label: const Text('Ver ejemplo de módulo'),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      ModuleOutlineView.routeName,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
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

/// Tarjeta CTA reutilizable
class _CtaCard extends StatelessWidget {
  final String title;
  final String emoji;
  final VoidCallback onTap;

  const _CtaCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.onTap,
  });

  factory _CtaCard.primary({
    required String title,
    required String emoji,
    required VoidCallback onTap,
  }) {
    return _CtaCard(title: title, emoji: emoji, onTap: onTap);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
