import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/env.dart';
import '../../widgets/aelion_appbar.dart';
import '../topics/topic_search_view.dart';
import '../modules/module_outline_view.dart';

class HomeView extends StatelessWidget {
  static const routeName = '/';

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final env = Env.env;
    final baseUrl = Env.baseUrl;
    final hasKey = Env.hasCvStudioKey;

    return Scaffold(
      appBar: AelionAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.neutral,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles del entorno',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('AELION_ENV: $env'),
                    Text('BASE_URL: $baseUrl'),
                    Row(
                      children: [
                        const Text('CV_STUDIO_API_KEY: '),
                        Chip(
                          label: Text(hasKey ? '✔️ configurada' : '❌ faltante'),
                          backgroundColor: hasKey
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, TopicSearchView.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: const Text('Buscar un tema'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, ModuleOutlineView.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text('Ver ejemplo de módulo'),
            ),
          ],
        ),
      ),
    );
  }
}
