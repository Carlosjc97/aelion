import 'dart:async';

import 'package:flutter/material.dart';

import 'package:edaptia/core/design_system/colors.dart';
import 'package:edaptia/core/design_system/typography.dart';
import 'package:edaptia/services/course/models.dart';

import '../models/lesson_view_config.dart';
import '../widgets/lesson_takeaway_card.dart';
import '../widgets/quiz_question_card.dart';

class MiniGameScreen extends StatefulWidget {
  const MiniGameScreen({super.key, required this.config});

  static const routeName = '/lesson/mini-game';

  final LessonViewConfig config;

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  late final List<AdaptiveMcq> _questions = widget.config.microQuiz;
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _timeLeft = 60;
  bool _showResult = false;
  int? _selectedIndex;
  Timer? _timer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    if (_questions.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (_timeLeft <= 0) {
          timer.cancel();
          setState(() => _completed = true);
        } else {
          setState(() => _timeLeft--);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.config.lessonTitle)),
        body: const Center(child: Text('Juego no disponible.')),
      );
    }

    final question = _questions[_currentIndex];
    final correctIndex = _correctIndex(question);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.lessonTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined),
                const SizedBox(width: 4),
                Text('$_timeLeft s'),
                const SizedBox(width: 12),
                const Icon(Icons.star_outline),
                const SizedBox(width: 4),
                Text('$_score pts'),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [EdaptiaColors.primary, EdaptiaColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _completed
                ? _buildResult()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.config.hook,
                        style: EdaptiaTypography.title2
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pregunta ${_currentIndex + 1} de ${_questions.length}',
                        style: EdaptiaTypography.body
                            .copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: QuizQuestionCard(
                          stem: question.stem,
                          options: _optionsFor(question),
                          selectedIndex: _selectedIndex,
                          correctIndex: correctIndex,
                          showResult: _showResult,
                          onSelect: _handleAnswer,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: (_currentIndex + 1) / _questions.length,
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                      ),
                      const SizedBox(height: 12),
                      Text('Racha: $_streak',
                          style: EdaptiaTypography.body
                              .copyWith(color: Colors.white)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _handleAnswer(int index) {
    if (_completed || _showResult) {
      return;
    }
    final question = _questions[_currentIndex];
    final isCorrect = index == _correctIndex(question);
    setState(() {
      _selectedIndex = index;
      _showResult = true;
      if (isCorrect) {
        _streak++;
        _score += 100 + (_timeLeft ~/ 2);
      } else {
        _streak = 0;
      }
    });

    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _showResult = false;
        _selectedIndex = null;
        if (_currentIndex + 1 >= _questions.length) {
          _completed = true;
          _timer?.cancel();
        } else {
          _currentIndex++;
        }
      });
    });
  }

  Widget _buildResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Juego completado',
            style: EdaptiaTypography.title1.copyWith(color: Colors.white)),
        const SizedBox(height: 12),
        Text('Marcador final: $_score',
            style: EdaptiaTypography.title2.copyWith(color: Colors.white70)),
        Text('Mejor racha: $_streak',
            style: EdaptiaTypography.body.copyWith(color: Colors.white70)),
        const SizedBox(height: 20),
        LessonTakeawayCard(takeaway: widget.config.takeaway),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  List<String> _optionsFor(AdaptiveMcq question) {
    final entries = question.options.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((entry) => '${entry.key}. ${entry.value}').toList();
  }

  int _correctIndex(AdaptiveMcq question) {
    final entries = question.options.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.indexWhere((entry) => entry.key == question.correct);
  }
}
