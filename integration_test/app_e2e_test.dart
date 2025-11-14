// dart:async not needed - provided by flutter_test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E harness', () {
    testWidgets(
      'completes onboarding and generates module 2 content after unlocking',
      (tester) async {
        await tester.pumpWidget(const _TestHarnessApp());
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('onboarding-screen')), findsOneWidget);

        await tester.tap(find.byKey(const Key('onboarding-complete')));
        await tester.pumpAndSettle();

        expect(find.text('Module Outline'), findsOneWidget);

        // Module 2 starts locked (visible after expanding the tile).
        await tester.tap(find.byKey(const Key('module-2-title')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('module-2-locked')), findsOneWidget);
        await tester.tap(find.byKey(const Key('module-2-title')));
        await tester.pump();

        // Start the free trial to unlock modules beyond M1.
        await tester.tap(find.byKey(const Key('start-trial')));
        await tester.pumpAndSettle();

        // Expand module 2 and wait for the fake generative fetch.
        await tester.tap(find.byKey(const Key('module-2-title')));
        await tester.pump();

        expect(find.byKey(const Key('module-2-spinner')), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byKey(const Key('module-2-spinner')), findsNothing);
        expect(find.byKey(const Key('module-2-lesson-0')), findsOneWidget);
        expect(find.byKey(const Key('module-2-lesson-1')), findsOneWidget);
      },
    );

    testWidgets(
      'gate quiz blocks when score <70 and unlocks after passing',
      (tester) async {
        await tester.pumpWidget(const _TestHarnessApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('onboarding-complete')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('module-2-title')));
        await tester.pumpAndSettle();

        // Open the gate quiz and intentionally fail (all answers incorrect).
        await tester.tap(find.byKey(const Key('module-2-gate-btn')));
        await tester.pumpAndSettle();

        for (var i = 0; i < _FakeGateQuizPage.questions.length; i++) {
          await tester.tap(find.byKey(Key('gate-q$i-option-0')));
        }

        await tester.tap(find.byKey(const Key('gate-quiz-submit')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('gate-quiz-result')), findsOneWidget);
        expect(find.textContaining('bloqueado'), findsOneWidget);

        await tester.tap(find.byKey(const Key('gate-quiz-finish')));
        await tester.pumpAndSettle();

        // Still locked after failing.
        expect(find.byKey(const Key('module-2-locked')), findsOneWidget);

        // Retry and pass with the correct answers.
        await tester.tap(find.byKey(const Key('module-2-gate-btn')));
        await tester.pumpAndSettle();

        for (var i = 0; i < _FakeGateQuizPage.questions.length; i++) {
          final correctIndex = _FakeGateQuizPage.questions[i].correctIndex;
          await tester.tap(
            find.byKey(Key('gate-q$i-option-$correctIndex')),
          );
        }

        await tester.tap(find.byKey(const Key('gate-quiz-submit')));
        await tester.pumpAndSettle();

        expect(find.textContaining('desbloqueado'), findsOneWidget);

        await tester.tap(find.byKey(const Key('gate-quiz-finish')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('module-2-locked')), findsNothing);
      },
    );
  });
}

class _TestHarnessApp extends StatefulWidget {
  const _TestHarnessApp();

  @override
  State<_TestHarnessApp> createState() => _TestHarnessAppState();
}

class _TestHarnessAppState extends State<_TestHarnessApp> {
  bool _onboardingComplete = false;
  bool _module2Unlocked = false;
  bool _module2Generating = false;
  bool _module2Generated = false;
  List<String> _module2Lessons = const [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _onboardingComplete
          ? _ModuleOutlineHarness(
              module2Unlocked: _module2Unlocked,
              module2Generating: _module2Generating,
              module2Generated: _module2Generated,
              module2Lessons: _module2Lessons,
              onStartTrial: () {
                setState(() => _module2Unlocked = true);
              },
              onGateQuizRequested: (context) async {
                final passed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const _FakeGateQuizPage(),
                  ),
                );
                if (passed == true) {
                  setState(() => _module2Unlocked = true);
                }
              },
              onModuleExpanded: (module, expanded) {
                if (module == 2 && expanded) {
                  _maybeGenerateModule2();
                }
              },
            )
          : _OnboardingHarness(
              onFinished: () {
                setState(() => _onboardingComplete = true);
              },
            ),
    );
  }

  Future<void> _maybeGenerateModule2() async {
    if (!_module2Unlocked || _module2Generated || _module2Generating) {
      return;
    }
    setState(() {
      _module2Generating = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _module2Generating = false;
      _module2Generated = true;
      _module2Lessons = const [
        'Segmenta audiencias con SQL',
        'Optimiza funnels con datos en vivo',
        'DiseA-a un reto final con KPIs'
      ];
    });
  }
}

class _OnboardingHarness extends StatelessWidget {
  const _OnboardingHarness({required this.onFinished});

  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          key: const Key('onboarding-screen'),
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Onboarding - Paso 1'),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('onboarding-complete'),
              onPressed: onFinished,
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleOutlineHarness extends StatelessWidget {
  const _ModuleOutlineHarness({
    required this.module2Unlocked,
    required this.module2Generating,
    required this.module2Generated,
    required this.module2Lessons,
    required this.onStartTrial,
    required this.onGateQuizRequested,
    required this.onModuleExpanded,
  });

  final bool module2Unlocked;
  final bool module2Generating;
  final bool module2Generated;
  final List<String> module2Lessons;
  final VoidCallback onStartTrial;
  final void Function(BuildContext context) onGateQuizRequested;
  final void Function(int moduleNumber, bool expanded) onModuleExpanded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Module Outline')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            key: const Key('start-trial'),
            onPressed: onStartTrial,
            child: const Text('Iniciar prueba de 7 dA-as'),
          ),
          const SizedBox(height: 24),
          ExpansionTile(
            key: const Key('module-1-tile'),
            title: const Text('Modulo 1', key: Key('module-1-title')),
            children: const [
              ListTile(
                leading: Icon(Icons.play_circle_outline),
                title: Text('Bienvenida'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            key: const Key('module-2-tile'),
            title: const Text('Modulo 2', key: Key('module-2-title')),
            onExpansionChanged: (expanded) =>
                onModuleExpanded(2, expanded == true),
            children: [
              if (!module2Unlocked)
                Column(
                  key: const Key('module-2-locked'),
                  children: [
                    const Text('Contenido premium bloqueado.'),
                    const SizedBox(height: 8),
                    TextButton(
                      key: const Key('module-2-gate-btn'),
                      onPressed: () => onGateQuizRequested(context),
                      child: const Text('Tomar gate quiz'),
                    ),
                  ],
                )
              else if (module2Generating)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircularProgressIndicator(key: Key('module-2-spinner')),
                      SizedBox(height: 12),
                      Text('Generando lecciones personalizadas...'),
                    ],
                  ),
                )
              else if (module2Generated)
                ...module2Lessons.asMap().entries.map(
                      (entry) => ListTile(
                        key: Key('module-2-lesson-${entry.key}'),
                        leading: const Icon(Icons.auto_stories),
                        title: Text(entry.value),
                      ),
                    )
              else
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Expande para generar el contenido.'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FakeGateQuizPage extends StatefulWidget {
  const _FakeGateQuizPage();

  static const questions = [
    _GateQuestion(
      text: 'MIN score for aprobar un quiz?',
      options: ['10%', '70%', '100%'],
      correctIndex: 1,
    ),
    _GateQuestion(
      text: 'JOIN recomendado para combinar leads con ventas?',
      options: ['CROSS', 'LEFT', 'RIGHT'],
      correctIndex: 1,
    ),
    _GateQuestion(
      text: 'Metricas clave para funnels?',
      options: ['CTR', 'ARPU', 'TTFB'],
      correctIndex: 0,
    ),
  ];

  @override
  State<_FakeGateQuizPage> createState() => _FakeGateQuizPageState();
}

class _FakeGateQuizPageState extends State<_FakeGateQuizPage> {
  late List<int?> _answers =
      List<int?>.filled(_FakeGateQuizPage.questions.length, null);
  _GateQuizResult? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gate Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _result == null ? _buildQuestions() : _buildResult(context),
      ),
    );
  }

  Widget _buildQuestions() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _FakeGateQuizPage.questions.length,
            itemBuilder: (context, index) {
              final question = _FakeGateQuizPage.questions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question.text,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...question.options.asMap().entries.map(
                            (entry) => _GateOptionTile(
                              key: Key('gate-q$index-option-${entry.key}'),
                              title: entry.value,
                              selected: _answers[index] == entry.key,
                              onTap: () {
                                setState(() {
                                  _answers[index] = entry.key;
                                });
                              },
                            ),
                          ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        FilledButton(
          key: const Key('gate-quiz-submit'),
          onPressed: _submitQuiz,
          child: const Text('Enviar'),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final passed = _result!.passed;
    final message = passed
        ? 'Modulo desbloqueado (${_result!.scorePct}%)'
        : 'Gate bloqueado (${_result!.scorePct}%)';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          key: const Key('gate-quiz-result'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (!passed)
          TextButton(
            key: const Key('gate-quiz-retry'),
            onPressed: () {
              setState(() {
                _result = null;
                _answers =
                    List<int?>.filled(_FakeGateQuizPage.questions.length, null);
              });
            },
            child: const Text('Reintentar'),
          ),
        const SizedBox(height: 8),
        FilledButton(
          key: const Key('gate-quiz-finish'),
          onPressed: () => Navigator.of(context).pop(passed),
          child: Text(passed ? 'Continuar' : 'Cerrar'),
        ),
      ],
    );
  }

  void _submitQuiz() {
    final total = _FakeGateQuizPage.questions.length;
    final correct = _FakeGateQuizPage.questions.asMap().entries.where(
          (entry) => _answers[entry.key] == entry.value.correctIndex,
        );
    final scorePct = ((correct.length / total) * 100).round();
    setState(() {
      _result = _GateQuizResult(
        scorePct: scorePct,
        passed: scorePct >= 70,
      );
    });
  }
}

class _GateOptionTile extends StatelessWidget {
  const _GateOptionTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class _GateQuestion {
  const _GateQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  final String text;
  final List<String> options;
  final int correctIndex;
}

class _GateQuizResult {
  const _GateQuizResult({
    required this.scorePct,
    required this.passed,
  });

  final int scorePct;
  final bool passed;
}
