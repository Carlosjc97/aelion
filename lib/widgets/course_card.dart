// lib/widgets/course_card.dart
import 'package:flutter/material.dart';

class Course {
  final String title;
  final String subtitle;
  final String imageUrl; // puede ser URL http(s) o path de asset
  final VoidCallback onTap;

  Course({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
  });
}

class CourseCard extends StatelessWidget {
  final Course course;
  final Color primaryColor;
  final Widget? background;

  const CourseCard({
    super.key,
    required this.course,
    required this.primaryColor,
    this.background,
  });

  ImageProvider _imageProvider(String source) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return NetworkImage(source);
    }
    // fallback: asset
    return AssetImage(source);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: InkWell(
        onTap: course.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 4),
                    color: Color(0x14000000),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Imagen
                  AspectRatio(
                    aspectRatio: 1.8,
                    child: Ink.image(
                      image: _imageProvider(course.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Texto
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF5A6B80),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (background != null)
              Positioned.fill(child: IgnorePointer(child: background!)),
          ],
        ),
      ),
    );
  }
}

// Decoraciones opcionales si ya las usabas
class DecorationContainerA extends StatelessWidget {
  final double top;
  final double left;
  const DecorationContainerA({super.key, this.top = -40, this.left = -30});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: top,
          left: left,
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x0F1565C0), // azul translÃºcido
            ),
          ),
        ),
      ],
    );
  }
}

class DecorationContainerB extends StatelessWidget {
  const DecorationContainerB({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // sin decoraciÃ³n
  }
}
