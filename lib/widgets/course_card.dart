import 'package:flutter/material.dart';
import 'package:learning_ia/core/app_colors.dart';
import 'package:learning_ia/widgets/quad_clipper.dart';

// A simple data model for the course card
class Course {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onTap;

  Course({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
  });
}

class CourseCard extends StatelessWidget {
  final Course course;
  final Color primaryColor;
  final Widget background;

  const CourseCard({
    super.key,
    required this.course,
    this.primaryColor = AppColors.primary,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ← declarada
// pero no se usa en ningún lado

    return InkWell(
      onTap: course.onTap,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Container(
        height: 180,
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(200),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            offset: const Offset(0, 5),
            blurRadius: 10,
            color: AppColors.primary.withAlpha(20),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Stack(
          children: <Widget>[
            background,
            Positioned(
              top: 20,
              left: 10,
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                backgroundImage: NetworkImage(course.imageUrl),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: _CardInfo(
                title: course.title,
                subtitle: course.subtitle,
                textColor: primaryColor == Colors.white ? AppColors.onSurface : Colors.white,
                chipColor: AppColors.secondary,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color textColor;
  final Color chipColor;

  const _CardInfo({
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 180,
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(color: textColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 5),
          _Chip(
            text: subtitle,
            color: chipColor,
            textColor: Colors.white,
          )
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Chip({
    required this.text,
    required this.color,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: color.withAlpha(200),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12),
      ),
    );
  }
}

// Decorative background widgets adapted from flutter_smart_course
class DecorationContainerA extends StatelessWidget {
  final Color color;
  final double top;
  final double left;

  const DecorationContainerA({
    super.key,
    this.color = AppColors.primary,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: top,
          left: left,
          child: CircleAvatar(
            radius: 100,
            backgroundColor: color.withAlpha(255),
          ),
        ),
        _smallContainer(color, 20, 40),
        Positioned(
          top: 20,
          right: -30,
          child: _circularContainer(80, Colors.transparent, borderColor: Colors.white),
        )
      ],
    );
  }

  Widget _smallContainer(Color color, double top, double left, {double radius = 10}) {
    return Positioned(
      top: top,
      left: left,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: color.withAlpha(255),
      ),
    );
  }

  Widget _circularContainer(double height, Color color, {Color borderColor = Colors.transparent, double borderWidth = 2}) {
    return Container(
      height: height,
      width: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
    );
  }
}

class DecorationContainerB extends StatelessWidget {
  const DecorationContainerB({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: -65,
          right: -65,
          child: CircleAvatar(
            radius: 70,
            backgroundColor: AppColors.secondary.withAlpha(100),
            child: const CircleAvatar(radius: 30, backgroundColor: Colors.white),
          ),
        ),
        Positioned(
          top: 35,
          right: -40,
          child: ClipRect(
            clipper: QuadClipper(),
            child: const CircleAvatar(backgroundColor: AppColors.secondary, radius: 40),
          ),
        ),
      ],
    );
  }
}
