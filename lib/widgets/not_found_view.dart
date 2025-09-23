// lib/widgets/not_found_view.dart
import 'package:flutter/material.dart';

class NotFoundView extends StatelessWidget {
  static const message = '404 - No existe la ruta';

  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
