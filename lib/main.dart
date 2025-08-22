import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const LearningIAApp());
}

class LearningIAApp extends StatelessWidget {
  const LearningIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning IA',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String _lesson = "Aquí aparecerá tu micro-lección ✨";

  void _generateLesson() {
    setState(() {
      _lesson = "👉 Lección generada para: ${_controller.text}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learning IA")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "¿Qué quieres aprender hoy?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateLesson,
              child: const Text("Generar lección"),
            ),
            const SizedBox(height: 24),
            Text(_lesson, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
