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
      // 🔴 "Resuelve un problema" se quita del UI porque aún no está lista.
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: courses.map((course) {
          return Semantics(
            label: 'Open \'${course.title}\'',
            child: SizedBox(
              width: cardWidth,
              height: 220,
              child: CourseCard(
                course: course,
                primaryColor:
                    course == courses.first ? AppColors.primary : Colors.white,
                background: course == courses.first
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
              _buildFeaturedCourses(context),
              const SizedBox(height: 22),
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