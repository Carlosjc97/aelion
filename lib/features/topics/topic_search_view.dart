import 'package:flutter/material.dart';
import '../../widgets/aelion_appbar.dart';
import '../../core/app_colors.dart';
import '../modules/module_outline_view.dart';

class TopicSearchView extends StatelessWidget {
  static const routeName = '/topics';

  const TopicSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'Introducción a Flutter',
      'Historia de Guayaquil',
      'Álgebra básica',
      'Sistemas solares',
    ];

    return Scaffold(
      appBar: AelionAppBar(title: 'Buscar tema'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Escribe un tema...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.neutral,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sugerencias',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestions[index]),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ModuleOutlineView.routeName,
                        arguments: suggestions[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
