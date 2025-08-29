import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/progress_service.dart';

class LessonView extends StatefulWidget {
  static const routeName = '/lesson';

  // IDs requeridos para progreso/bloqueos
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

  // Checklist de práctica (3 pasos de ejemplo, persistentes por lección)
  final int _practiceLen = 3;
  late List<bool> _practiceChecks;

  bool get _locked =>
      widget.isPremiumEnabled && widget.isPremiumLesson; // candado solo si flag activo

  @override
  void initState() {
    super.initState();
    _lang = (widget.initialLang == 'en') ? 'en' : 'es';

    // Demo bilingüe: en producción esto vendría de la API/outline
    _contentEs = widget.content;
    _contentEn = 'English version of: ${widget.content}';

    _mem = _lang == 'es'
        ? 'MEM: “Piensa en bloques: UI → Estado → Acciones.”'
        : 'MEM: “Think in blocks: UI → State → Actions.”';

    _practiceChecks = List<bool>.filled(_practiceLen, false);
    _loadPractice();
  }

  Future<void> _loadPractice() async {
    final data = await progress.loadLessonChecklist(
      courseId: widget.courseId,
      moduleId: widget.moduleId,
      lessonId: widget.lessonId,
      length: _practiceLen,
    );
    if (!mounted) return;
    setState(() => _practiceChecks = data);
  }

  Future<void> _savePractice() async {
    await progress.saveLessonChecklist(
      courseId: widget.courseId,
      moduleId: widget.moduleId,
      lessonId: widget.lessonId,
      checks: _practiceChecks,
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
    // Marca como completada en progreso local
    await progress.markLessonCompleted(
      courseId: widget.courseId,
      moduleId: widget.moduleId,
      lessonId: widget.lessonId,
    );
    if (!mounted) return;
    Navigator.pop(context, {'completed': true});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lección marcada como completada ✅')),
    );
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

                    // SECCIONES
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionTitle(text: _lang == 'es' ? 'Objetivo' : 'Objective'),
                            Text(
                              _lang == 'es'
                                  ? 'Al finalizar, podrás explicar el concepto y aplicarlo en un ejemplo simple.'
                                  : 'By the end, you will explain the concept and apply it in a simple example.',
                              style: text.bodyLarge,
                            ),
                            const SizedBox(height: 16),

                            _SectionTitle(text: _lang == 'es' ? 'Concepto' : 'Concept'),
                            Text(
                              _lang == 'es' ? _contentEs : _contentEn,
                              style: text.bodyLarge,
                            ),
                            const SizedBox(height: 16),

                            _SectionTitle(text: _lang == 'es' ? 'Ejemplo' : 'Example'),
                            Text(
                              _lang == 'es'
                                  ? 'Piensa en un contador con botón: al presionar, aumenta el estado y la UI se actualiza.'
                                  : 'Think of a counter with a button: pressing increases state and UI updates.',
                              style: text.bodyLarge,
                            ),
                            const SizedBox(height: 16),

                            _SectionTitle(text: _lang == 'es' ? 'Práctica' : 'Practice'),
                            ...List.generate(_practiceLen, (i) {
                              final labelEs = [
                                'Crear un widget básico',
                                'Actualizar estado con una acción',
                                'Mostrar resultado en pantalla',
                              ][i];
                              final labelEn = [
                                'Create a basic widget',
                                'Update state with an action',
                                'Render the result on screen',
                              ][i];
                              return CheckboxListTile(
                                value: _practiceChecks[i],
                                onChanged: (v) async {
                                  setState(() => _practiceChecks[i] = v ?? false);
                                  await _savePractice();
                                },
                                title: Text(_lang == 'es' ? labelEs : labelEn),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _markDone,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(_lang == 'es'
                          ? 'Marcar como completada'
                          : 'Mark as completed'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
