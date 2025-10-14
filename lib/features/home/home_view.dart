import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:aelion/core/app_colors.dart';
import 'package:aelion/features/modules/module_outline_view.dart';
import 'package:aelion/l10n/app_localizations.dart';
import 'package:aelion/services/google_sign_in_helper.dart';
import 'package:aelion/widgets/skeleton.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final topic = _controller.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (topic.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.homeSnackMissingTopic)));
      return;
    }

    if (_loading) return;

    setState(() => _loading = true);
    try {
      if (!mounted) return;
      final languageCode = Localizations.localeOf(context).languageCode;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ModuleOutlineView(
            topic: topic,
            goal: 'Build expertise in $topic',
            language: languageCode,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSignOut() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await FirebaseAuth.instance.signOut();
      if (!kIsWeb) {
        final helper = await GoogleSignInHelper.instance();
        await helper.signOut();
      }
    } catch (error) {
      debugPrint('[HomeView] signOut error: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.homeSignOutError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    final content = ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (user != null) _UserCard(user: user, l10n: l10n),
        _PromptCard(
          controller: _controller,
          generateLabel: l10n.homeGenerate,
          loading: _loading,
          onSubmit: _submit,
          hintText: l10n.homeInputHint,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          children: [
            _SuggestionChip(
              label: l10n.homeSuggestionMath,
              onTap: () {
                _controller.text = l10n.homeSuggestionMath;
                _submit();
              },
            ),
            _SuggestionChip(
              label: l10n.homeSuggestionEnglish,
              onTap: () {
                _controller.text = l10n.homeSuggestionEnglish;
                _submit();
              },
            ),
            _SuggestionChip(
              label: l10n.homeSuggestionHistory,
              onTap: () {
                _controller.text = l10n.homeSuggestionHistory;
                _submit();
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(l10n.homeShortcuts, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        _ShortcutCard(
          icon: Icons.menu_book,
          title: l10n.homeShortcutCourse,
          subtitle: l10n.homeShortcutCourseSubtitle,
          onTap: () {
            _controller.text = l10n.homePrefillCourse;
            _submit();
          },
        ),
        const SizedBox(height: 12),
        _ShortcutCard(
          icon: Icons.language,
          title: l10n.homeShortcutLanguage,
          subtitle: l10n.homeShortcutLanguageSubtitle,
          onTap: () {
            _controller.text = l10n.homePrefillLanguage;
            _submit();
          },
        ),
        const SizedBox(height: 12),
        _ShortcutCard(
          icon: Icons.lightbulb_outline,
          title: l10n.homeShortcutProblem,
          subtitle: l10n.homeShortcutProblemSubtitle,
          onTap: () {
            _controller.text = l10n.homePrefillProblem;
            _submit();
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.homeLogoutTooltip,
            onPressed: _handleSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            content,
            if (_loading) const _HomeLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.l10n});

  final User user;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            _initialFor(user) ?? '?',
          ),
        ),
        title: Text(
          user.displayName?.isNotEmpty == true
              ? user.displayName!
              : l10n.homeUserFallback,
        ),
        subtitle: Text(user.email ?? l10n.homeUserNoEmail),
      ),
    );
  }

  String? _initialFor(User user) {
    final displayName = user.displayName?.trim();
    if (displayName?.isNotEmpty == true) return displayName![0].toUpperCase();
    final mail = user.email?.trim();
    if (mail?.isNotEmpty == true) return mail![0].toUpperCase();
    return null;
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.controller,
    required this.generateLabel,
    required this.loading,
    required this.onSubmit,
    required this.hintText,
  });

  final TextEditingController controller;
  final String generateLabel;
  final bool loading;
  final VoidCallback onSubmit;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.neutral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.homeGreeting,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: loading ? null : onSubmit,
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(generateLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _HomeLoadingOverlay extends StatelessWidget {
  const _HomeLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.92),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Skeleton(height: 20, width: 220),
              SizedBox(height: 16),
              Skeleton(height: 56, width: 200),
            ],
          ),
        ),
      ),
    );
  }
}
