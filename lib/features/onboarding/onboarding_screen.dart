import 'package:flutter/material.dart';

import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _pageCount = 5;
  final PageController _pageController = PageController();

  int _currentPage = 0;
  String? _ageRange;
  final Set<String> _interests = <String>{};
  String? _education;
  bool? _isFirstTimeSql;
  bool _wantsBetaTester = false;
  bool _submitting = false;

  static final List<_SelectableOption> _ageOptions = <_SelectableOption>[
    _SelectableOption(
      '18_24',
      (l10n) => l10n.onboardingAge18_24,
    ),
    _SelectableOption(
      '25_34',
      (l10n) => l10n.onboardingAge25_34,
    ),
    _SelectableOption(
      '35_44',
      (l10n) => l10n.onboardingAge35_44,
    ),
    _SelectableOption(
      '45_plus',
      (l10n) => l10n.onboardingAge45Plus,
    ),
  ];

  static final List<_SelectableOption> _interestOptions = <_SelectableOption>[
    _SelectableOption('sql', (l10n) => l10n.onboardingInterestSql),
    _SelectableOption('python', (l10n) => l10n.onboardingInterestPython),
    _SelectableOption('excel', (l10n) => l10n.onboardingInterestExcel),
    _SelectableOption('data_analysis', (l10n) => l10n.onboardingInterestData),
    _SelectableOption('marketing', (l10n) => l10n.onboardingInterestMarketing),
  ];

  static final List<_SelectableOption> _educationOptions = <_SelectableOption>[
    _SelectableOption('secondary', (l10n) => l10n.onboardingEducationSecondary),
    _SelectableOption(
        'university', (l10n) => l10n.onboardingEducationUniversity),
    _SelectableOption('postgrad', (l10n) => l10n.onboardingEducationPostgrad),
    _SelectableOption(
        'self_taught', (l10n) => l10n.onboardingEducationSelfTaught),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (_currentPage >= _pageCount - 1) {
      await _submit();
      return;
    }
    final nextPage = _currentPage + 1;
    setState(() => _currentPage = nextPage);
    await _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleBack() async {
    if (_currentPage == 0) return;
    final previousPage = _currentPage - 1;
    setState(() => _currentPage = previousPage);
    await _pageController.animateToPage(
      previousPage,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleSkip() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final service = OnboardingService();
    try {
      await service.skip(
        partial: OnboardingAnswers(
          ageRange: _ageRange,
          interests: _interests.toList(),
          education: _education,
          isFirstTimeSql: _isFirstTimeSql,
          wantsBetaTester: _wantsBetaTester,
        ),
      );
      widget.onFinished?.call();
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final service = OnboardingService();
    try {
      await service.submit(
        OnboardingAnswers(
          ageRange: _ageRange,
          interests: _interests.toList(),
          education: _education,
          isFirstTimeSql: _isFirstTimeSql,
          wantsBetaTester: _wantsBetaTester,
        ),
      );
      widget.onFinished?.call();
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showErrorSnackBar(Object error) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final message = l10n?.onboardingError ??
        'We could not save your answers. Please try again.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _canProceed(int page) {
    switch (page) {
      case 0:
        return _ageRange != null;
      case 1:
        return _interests.isNotEmpty;
      case 2:
        return _education != null;
      case 3:
        return _isFirstTimeSql != null;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final progress = (_currentPage + 1) / _pageCount;
    final canProceed = _canProceed(_currentPage) && !_submitting;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.onboardingTitle),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _handleSkip,
            child: Text(l10n.onboardingSkip),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.onboardingProgressLabel} ${_currentPage + 1}/$_pageCount',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _QuestionCard(child: _buildAgeQuestion(l10n, theme)),
                  _QuestionCard(child: _buildInterestsQuestion(l10n, theme)),
                  _QuestionCard(child: _buildEducationQuestion(l10n, theme)),
                  _QuestionCard(child: _buildSqlQuestion(l10n, theme)),
                  _QuestionCard(child: _buildBetaQuestion(l10n, theme)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _currentPage == 0 || _submitting ? null : _handleBack,
                      child: Text(l10n.onboardingBack),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: canProceed
                          ? () {
                              if (_currentPage == _pageCount - 1) {
                                _submit();
                              } else {
                                _handleNext();
                              }
                            }
                          : null,
                      child: Text(
                        _currentPage == _pageCount - 1
                            ? l10n.onboardingStart
                            : l10n.onboardingNext,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeQuestion(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.onboardingQuestionAge, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: DropdownMenu<String>(
            initialSelection: _ageRange,
            enabled: !_submitting,
            label: Text(l10n.onboardingSelectLabel),
            dropdownMenuEntries: _buildMenuEntries(_ageOptions, l10n),
            onSelected: (value) {
              if (value == null) return;
              setState(() => _ageRange = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsQuestion(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.onboardingQuestionInterests,
            style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _interestOptions.map((option) {
            final selected = _interests.contains(option.value);
            return FilterChip(
              label: Text(option.labelBuilder(l10n)),
              selected: selected,
              onSelected: _submitting
                  ? null
                  : (value) {
                      setState(() {
                        if (value) {
                          _interests.add(option.value);
                        } else {
                          _interests.remove(option.value);
                        }
                      });
                    },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEducationQuestion(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.onboardingQuestionEducation,
            style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: DropdownMenu<String>(
            initialSelection: _education,
            enabled: !_submitting,
            label: Text(l10n.onboardingSelectLabel),
            dropdownMenuEntries: _buildMenuEntries(_educationOptions, l10n),
            onSelected: (value) {
              if (value == null) return;
              setState(() => _education = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSqlQuestion(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.onboardingQuestionFirstSql,
            style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          children: [
            ChoiceChip(
              label: Text(l10n.commonYes),
              selected: _isFirstTimeSql == true,
              onSelected: _submitting
                  ? null
                  : (_) {
                      setState(() => _isFirstTimeSql = true);
                    },
            ),
            ChoiceChip(
              label: Text(l10n.commonNo),
              selected: _isFirstTimeSql == false,
              onSelected: _submitting
                  ? null
                  : (_) {
                      setState(() => _isFirstTimeSql = false);
                    },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBetaQuestion(AppLocalizations l10n, ThemeData theme) {
    final cardColor = theme.colorScheme.surfaceContainerHighest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.onboardingQuestionBeta, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingBetaDescription,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _wantsBetaTester,
                onChanged: _submitting
                    ? null
                    : (value) {
                        setState(() => _wantsBetaTester = value ?? false);
                      },
                title: Text(
                  l10n.onboardingBetaOptIn,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<DropdownMenuEntry<String>> _buildMenuEntries(
    List<_SelectableOption> options,
    AppLocalizations l10n,
  ) {
    return options
        .map(
          (option) => DropdownMenuEntry<String>(
            value: option.value,
            label: option.labelBuilder(l10n),
          ),
        )
        .toList();
  }
}

class _SelectableOption {
  const _SelectableOption(this.value, this.labelBuilder);

  final String value;
  final String Function(AppLocalizations l10n) labelBuilder;
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: child,
      ),
    );
  }
}
