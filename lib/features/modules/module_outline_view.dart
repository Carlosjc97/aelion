import 'package:flutter/material.dart';
import '../../widgets/aelion_appbar.dart';
import '../../core/app_colors.dart';

class ModuleOutlineView extends StatelessWidget {
  static const routeName = '/module';

  final String? topic;

  const ModuleOutlineView({super.key, this.topic});

  @override
  Widget build(BuildContext context) {
    final title = topic ?? 'Módulo de ejemplo';

    final sections = [
      {'titulo': 'Definición', 'contenido': 'Breve descripción del tema.'},
      {
        'titulo': 'Ejemplo práctico',
        'contenido': 'Aplicación real o ejercicio.',
      },
      {
        'titulo': 'Para profundizar',
        'contenido': 'Recursos y lecturas recomendadas.',
      },
    ];

    return Scaffold(
      appBar: AelionAppBar(title: title),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Card(
            color: AppColors.neutral,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(section['titulo']!),
              subtitle: Text(section['contenido']!),
            ),
          );
        },
      ),
    );
  }
}
