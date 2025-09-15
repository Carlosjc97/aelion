import 'package:flutter/material.dart';
import 'package:learning_ia/core/app_colors.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';

class HomeView extends StatefulWidget {
  static const routeName = '/';
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final topic = _controller.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un tema para continuar')),
      );
      return;
    }
    if (_loading) return;

    setState(() => _loading = true);
    try {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ModuleOutlineView(topic: topic)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Hero prompt
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.neutral),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Qué quieres aprender hoy?',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      hintText: 'Ej: Álgebra en 7 días, Gramática inglesa…',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _submit,
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: const Text('Generar plan con IA'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Chips sugerencias
            Wrap(
              spacing: 8,
              children: [
                _SuggestionChip(
                  label: 'Matemáticas',
                  onTap: () {
                    _controller.text = 'Matemáticas básicas';
                    _submit();
                  },
                ),
                _SuggestionChip(
                  label: 'Inglés',
                  onTap: () {
                    _controller.text = 'Inglés conversacional';
                    _submit();
                  },
                ),
                _SuggestionChip(
                  label: 'Historia',
                  onTap: () {
                    _controller.text = 'Historia de Roma';
                    _submit();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Accesos secundarios
            Text('Atajos', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _ShortcutCard(
              icon: Icons.menu_book,
              title: 'Toma un curso',
              subtitle: 'Microcursos creados por IA',
              onTap: () => _controller.text = 'Curso rápido de Flutter',
            ),
            const SizedBox(height: 12),
            _ShortcutCard(
              icon: Icons.language,
              title: 'Aprende un idioma',
              subtitle: 'Vocabulario y gramática práctica',
              onTap: () => _controller.text = 'Inglés en 1 mes',
            ),
            const SizedBox(height: 12),
            _ShortcutCard(
              icon: Icons.lightbulb_outline,
              title: 'Resuelve un problema',
              subtitle: 'De la duda a un plan guiado',
              onTap: () => _controller.text = 'Resolver integrales',
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
