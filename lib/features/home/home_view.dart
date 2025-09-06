import 'package:flutter/material.dart';
import 'package:learning_ia/core/app_colors.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/features/topics/topic_search_view.dart';
import 'package:learning_ia/widgets/course_card.dart';

class HomeView extends StatelessWidget {
  static const routeName = '/';

  const HomeView({super.key});

  Widget _buildFeaturedCourses(BuildContext context) {
    final courses = <Course>[
      Course(
        title: 'Toma un curso',
        subtitle: 'Explora módulos',
        imageUrl:
            'https://d1mo3tzxttab3n.cloudfront.net/static/img/shop/560x580/vint0080.jpg',
        onTap: () => Navigator.pushNamed(
          context,
          ModuleOutlineView.routeName,
          arguments: 'Introducción a la IA',
        ),
      ),
      Course(
        title: 'Aprende un idioma',
        subtitle: 'Práctica guiada',
        imageUrl:
            'https://hips.hearstapps.com/esquireuk.cdnds.net/16/39/980x980/square-1475143834-david-gandy.jpg?resize=480:*',
        onTap: () => Navigator.pushNamed(context, TopicSearchView.routeName),
      ),
      Course(
        title: 'Resuelve un problema',
        subtitle: 'Próximamente',
        imageUrl:
            'https://www.visafranchise.com/wp-content/uploads/2019/05/patrick-findaro-visa-franchise-square.jpg',
        onTap: () => Navigator.pushNamed(context, TopicSearchView.routeName),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          const SizedBox(width: 6),
          for (final course in courses)
            CourseCard(
              course: course,
              primaryColor: course == courses.first
                  ? AppColors.primary
                  : Colors.white,
              background: course == courses.first
                  ? const DecorationContainerA(top: -50, left: -30)
                  : const DecorationContainerB(),
            ),
          const SizedBox(width: 6),
        ],
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

              // Cards horizontales
              _buildFeaturedCourses(context),
            ],
          ),
        ),
      ),
    );
  }
}
