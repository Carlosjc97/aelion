import 'package:flutter/material.dart';
import 'package:learning_ia/core/app_colors.dart';
import 'package:learning_ia/widgets/aelion_appbar.dart';

class TopicSearchView extends StatefulWidget {
  static const routeName = '/topics';

  const TopicSearchView({super.key});

  @override
  State<TopicSearchView> createState() => _TopicSearchViewState();
}

class _TopicSearchViewState extends State<TopicSearchView> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final languages = {
      '🇪🇸': 'Español',
      '🇬🇧': 'Inglés',
      '🇵🇹': 'Portugués',
      '🇫🇷': 'Francés',
      '🇮🇹': 'Italiano',
    };

    return Scaffold(
      appBar: const AelionAppBar(title: 'Aprende un idioma'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Practica a tu ritmo · 5 minutos al día',
              style: text.bodyLarge?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7), // 👈 reemplazo
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: languages.entries.map((entry) {
                final isSelected = _selectedLanguage == entry.value;
                return ActionChip(
                  avatar: Text(entry.key, style: const TextStyle(fontSize: 18)),
                  label: Text(entry.value),
                  onPressed: () {
                    setState(() {
                      _selectedLanguage = entry.value;
                    });
                  },
                  backgroundColor: isSelected
                      ? AppColors.primary.withValues(alpha: 0.2) // 👈 reemplazo
                      : AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (_selectedLanguage != null)
              Text(
                'Temas para $_selectedLanguage:',
                style: text.titleMedium,
              ),
            // TODO: Display topics for the selected language
          ],
        ),
      ),
    );
  }
}