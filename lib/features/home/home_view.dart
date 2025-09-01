import 'package:flutter/material.dart';
class HomeView extends StatelessWidget {
  static const routeName = '/';

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aelion')),
      body: Container(color: Colors.blue),
    );
  }
}
