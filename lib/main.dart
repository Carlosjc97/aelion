import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga opcional del .env (solo si existe localmente). No lo empaques en assets.
  try {
    await dotenv.load(fileName: ".env"); // raíz del proyecto
  } catch (_) {
    // Si no existe (p.ej. en CI o release), sigue sin tronar
    debugPrint("[Aelion] .env no encontrado (ok en CI/release).");
  }

  // Guardia: si la app intenta usar la key y no está, que no reviente
  final key = dotenv.env['CV_STUDIO_API_KEY'] ?? '';
  if (key.isEmpty || key == 'changeme') {
    debugPrint("[Aelion] CV_STUDIO_API_KEY ausente/placeholder. Evita llamadas reales.");
  }

  runApp(const AelionApp());
}

class AelionApp extends StatelessWidget {
  const AelionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aelion',
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
      appBar: AppBar(title: const Text("Aelion")),
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