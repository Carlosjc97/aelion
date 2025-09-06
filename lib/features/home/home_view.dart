import 'package:flutter/material.dart';
import 'package:learning_ia/core/app_colors.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/features/topics/topic_search_view.dart';
import 'package:learning_ia/widgets/course_card.dart';

class HomeView extends StatelessWidget {
  static const routeName = '/';

  const HomeView({super.key});

  Widget _buildFeaturedCourses(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45;

    // Solo 2 cards (el smoke test espera 2)
    final courses = <Course>[
      Course(
        title: 'Toma un curso',
        subtitle: 'Explora módulos',
        imageUrl: 'assets/home/course.png',
        onTap: () => Navigator.pushNamed(
          context,
          ModuleOutlineView.routeName,
          arguments: 'Introducción a la IA',
        ),
      ),
      Course(
        title: 'Aprende un idioma',
        subtitle: 'Práctica guiada',
        imageUrl: 'assets/home/language.png',
        onTap: () => Navigator.pushNamed(context, TopicSearchView.routeName),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: courses.map((course) {
          final isFirst = course.title == 'Toma un curso';
          return Semantics(
            label: 'Open \'${course.title}\'',
            child: SizedBox(
              width: cardWidth,
              height: 220,
              child: CourseCard(
                key: isFirst ? const Key('course_card_toma_un_curso') : null,
                course: course,
                primaryColor: isFirst ? AppColors.primary : Colors.white,
                background: isFirst
                    ? const DecorationContainerA(top: -50, left: -30)
                    : const DecorationContainerB(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Aelion')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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

              // Cards horizontales
              _buildFeaturedCourses(context),

              const SizedBox(height: 22),

              // Trending / populares
              Text(
                'Cursos populares',
                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTrendingCourses(context),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTrendingCourses(BuildContext context) {
  final trendingCourses = [
    'Introducción a la IA',
    'Productividad con IA',
    'Fundamentos de UX',
    'Finanzas personales básicas',
  ];

  return Column(
    children: trendingCourses.map((courseName) {
      return Card(
        elevation: 0,
        color: AppColors.surface,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: const Icon(Icons.auto_awesome, color: AppColors.secondary),
          title: Text(courseName),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(
              context,
              ModuleOutlineView.routeName,
              arguments: courseName,
            );
          },
        ),
      );
    }).toList(),
  );
}
```0