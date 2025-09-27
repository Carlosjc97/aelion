import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:learning_ia/l10n/app_localizations.dart';
import 'package:learning_ia/core/app_colors.dart';
import 'package:learning_ia/features/modules/module_outline_view.dart';
import 'package:learning_ia/services/google_sign_in_helper.dart';

class HomeView extends StatefulWidget {
  static const routeName = '/';
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _controller = TextEditingController();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeSnackMissingTopic)),
      );
      return;
    }

    if (_loading) return;

    setState(() => _loading = true);
    try {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ModuleOutlineView(topic: topic),
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
        final googleSignIn = await GoogleSignInHelper.instance();
        await googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint('[HomeView] signOut error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeSignOutError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (user != null)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      (user.displayName?.trim().isNotEmpty ?? false)
                          ? user.displayName!.trim()[0].toUpperCase()
                          : (user.email?.trim().isNotEmpty ?? false)
                              ? user.email!.trim()[0].toUpperCase()
                              : '?',
                    ),
                  ),
                  title: Text(
                    user.displayName?.isNotEmpty == true
                        ? user.displayName!
                        : l10n.homeUserFallback,
                  ),
                  subtitle: Text(user.email ?? l10n.homeUserNoEmail),
                ),
              ),
            Container(
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
                    l10n.homeGreeting,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: l10n.homeInputHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _submit,
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(l10n.homeGenerate),
                    ),
                  ),
                ],
              ),
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
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
