import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:edaptia/features/support/help_support_screen.dart';
import 'package:edaptia/features/usage/usage_dashboard_page.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/language_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String? _currentLanguage;
  bool _isSavingLanguage = false;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final stored = await LanguagePreferences.getLanguageCode();
    if (!mounted) return;
    setState(() => _currentLanguage = stored);
  }

  String _resolvedLanguage(BuildContext context) {
    final lang = _currentLanguage;
    if (lang == 'es' || lang == 'en') {
      return lang!;
    }
    final localeCode = Localizations.localeOf(context).languageCode;
    return localeCode == 'es' ? 'es' : 'en';
  }

  Future<void> _handleLanguageChanged(String? newLang) async {
    if (newLang == null || newLang == _currentLanguage) return;
    setState(() {
      _currentLanguage = newLang;
      _isSavingLanguage = true;
    });
    await LanguagePreferences.setPreferredLanguageCode(newLang);
    if (!mounted) return;
    Phoenix.rebirth(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final languageCode = _resolvedLanguage(context);
    final languageSubtitle = languageCode == 'es'
        ? l10n.settingsLanguageSpanish
        : l10n.settingsLanguageEnglish;
    final isSpanish = l10n.localeName.startsWith('es');
    final usageTitle = isSpanish ? 'Uso de IA' : 'AI usage';
    final usageSubtitle =
        isSpanish ? 'Tokens y costos recientes' : 'Recent tokens and costs';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              l10n.settingsGeneralSection,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(l10n.settingsLanguageTitle),
              subtitle:
                  Text(languageSubtitle, style: theme.textTheme.bodySmall),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: languageCode,
                  onChanged: _isSavingLanguage ? null : _handleLanguageChanged,
                  items: [
                    DropdownMenuItem(
                      value: 'es',
                      child: Text(l10n.settingsLanguageSpanish),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(l10n.settingsLanguageEnglish),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _SettingsTile(
              icon: Icons.support_agent_outlined,
              title: l10n.settingsHelpSupport,
              subtitle: l10n.settingsHelpSupportSubtitle,
              onTap: () {
                Navigator.of(context).pushNamed(HelpSupportScreen.routeName);
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: _SettingsTile(
              icon: Icons.insights_outlined,
              title: usageTitle,
              subtitle: usageSubtitle,
              onTap: () {
                Navigator.of(context).pushNamed(UsageDashboardPage.routeName);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
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
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
