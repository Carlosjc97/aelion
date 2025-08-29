import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/progress_service.dart';

class LessonView extends StatefulWidget {
  static const routeName = '/lesson';

  /// Identificadores requeridos para guardar progreso/checklist
  final String courseId;
  final String moduleId;
  final String lessonId;

  final String title;
  final String content;

  /// Feature-flag global para mostrar elementos premium (oculto por defecto).
  final bool isPremiumEnabled;

  /// Si esta lección es premium (cuando el flag está activado, se aplica el candado).
  final bool isPremiumLesson;

  /// Idioma inicial de la lección: 'es' o 'en'
  final String initialLang;

  const LessonView({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
    this.title = 'Lección',
    this.content = 'Contenido…',
    this.isPremiumEnabled = false,
    this.isPremiumLesson = false,
    this.initialLang = 'es',
  });

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  final progress = ProgressService();

  late String _lang; // 'es' | 'en'
  late String _mem;  // mnemotecnia
  late String _contentEs;
  late String _contentEn;

  /// Lista de checks: cada item = {"text": String, "done": bool}
  List<Map<String, dynamic>> _checklist = [];
  bool _loadingChecklist = true;

  bool get _locked =>
      widget.isPremiumEnabled && widget.isPremiumLesson; // candado solo si flag activo

  @override
  void initState() {
    super.initState();
    _lang = (widget.initialLang == 'en') ? 'en' : 'es';

    // Demo bilingüe: en producción esto vendría de la API/outline
    _contentEs = widget.content;
    _contentEn = 'English version of: ${widget.content}';

    // “Mem” (mnemotecnia) simple de ejemplo
    _mem = _lang == 'es'
        ? 'MEM: “Piensa en bloques: UI → Estado → Acciones.”'
        : 'MEM: “Think in blocks: UI → State → Actions.”';

    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    setState(() => _loadingChecklist = true);

    final items = await progress.loadLessonChecklist(
      courseId: widget.courseId,
      moduleId: widget.moduleId,
      lessonId: widget.lessonId,
    );

    // Si no hay checklist guardado, generamos uno básico inicial
    _checklist = items.isNotEmpty
        ? items
        : <Map<String, dynamic>>[
            {
              'text': _lang == 'es'
                  ? 'Leer la explicación de la lección'
                  : 'Read the lesson explanation',
              'done': false,
            },
            {
              'text': _lang == 'es'
                  ? 'Tomar notas clave'
                  : 'Take keynotes',
              'done': false,
            },
            {
              'text': _lang == 'es'
                  ? 'Hacer un pequeño ejercicio'
                  : 'Do a small exercise',
              'done': false,
            },
            {
              'text': _lang == 'es'
                  ? 'Repasar el contenido'
                  : 'Review the content',
              'done': false,
            },
          ];

    setState(() => _loadingChecklist = false);
  }

  Future<void> _saveChecklist() async {
    await progress.saveLessonChecklist(
      courseId: widget.courseId,
      moduleId: widget.moduleId,
      lessonId: widget.lessonId,
      checklist: _checklist,
    );
  }

  void _switchLang() {
    setState(() {
      _lang = _lang == 'es' ? 'en' : 'es';
      _mem = _lang == 'es'
          ? 'MEM: “Piensa en bloques: UI → Estado → Acciones.”'
          : 'MEM: “Think in blocks: UI → State → Actions.”';
    });
  }

  Future<void> _markDone() async {
    // Guarda checklist antes de marcar done
    await _saveChecklist();

    // Marca como completada en progreso (y desbloquea la siguiente)
    final updated = await progress.markLessonCompleted(
      courseId: widget.courseId,
      moduleId: widget.moduleId,
      lessonId: widget.lessonId,
    );

    if (!mounted) return;

    if (updated != null) {
      Navigator.pop(context, {'completed': true});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lección marcada como completada ✅')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el progreso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Toggle idioma
          IconButton(
            tooltip: _lang == 'es' ? 'Switch to English' : 'Cambiar a Español',
            onPressed: _locked ? null : _switchLang,
            icon: const Icon(Icons.translate_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _locked
            ? _PremiumPaywall(
                title: widget.title,
                onUpgrade: () {
                  // Aquí podrías abrir tu flujo de suscripción
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Premium pronto ✨')),
                  );
                },
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // MEM (mnemotecnia)
                    Card(
                      color: AppColors.neutral,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Text(_mem, style: text.bodyMedium),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Contenido bilingüe
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _lang == 'es' ? _contentEs : _contentEn,
                              style: text.bodyLarge,
                            ),
                            const SizedBox(height: 16),

                            // Checklist
                            Text(
                              _lang == 'es' ? 'Checklist' : 'Checklist',
                              style: text.titleMedium,
                            ),
                            const SizedBox(height: 8),

                            if (_loadingChecklist)
                              const Center(
                                  child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ))
                            else
                              ..._checklist.asMap().entries.map((entry) {
                                final i = entry.key;
                                final item = entry.value;
                                final done = (item['done'] as bool?) ?? false;
                                final label =
                                    (item['text'] as String?) ?? '—';

                                return CheckboxListTile(
                                  value: done,
                                  title: Text(label),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (v) async {
                                    setState(() {
                                      _checklist[i]['done'] = v ?? false;
                                    });
                                    await _saveChecklist();
                                  },
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _markDone,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        _lang == 'es'
                            ? 'Marcar como completada'
                            : 'Mark as completed',
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PremiumPaywall extends StatelessWidget {
  final String title;
  final VoidCallback onUpgrade;
  const _PremiumPaywall({required this.title, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline_rounded, size: 72),
          const SizedBox(height: 12),
          Text('Lección Premium', style: text.headlineMedium),
          const SizedBox(height: 6),
          Text(
            '“$title” está disponible en Premium.\n'
            'Desbloquea acceso a todas las lecciones y funciones avanzadas.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onUpgrade,
            child: const Text('Desbloquear con Premium'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}
