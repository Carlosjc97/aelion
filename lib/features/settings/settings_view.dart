import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:edaptia/features/paywall/paywall_modal.dart';
import 'package:edaptia/features/support/help_support_screen.dart';
import 'package:edaptia/l10n/app_localizations.dart';
import 'package:edaptia/services/entitlements_service.dart';
import 'package:edaptia/services/google_play_billing_service.dart';
import 'package:edaptia/services/language_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String? _currentLanguage;
  bool _isSavingLanguage = false;
  Future<bool>? _premiumStatusFuture;
  final EntitlementsService _entitlements = EntitlementsService();

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _premiumStatusFuture = _entitlements.isPremium();
  }

  Future<void> _loadLanguage() async {
    final stored = await LanguagePreferences.getLanguageCode();
    if (!mounted) return;
    setState(() => _currentLanguage = stored);
  }

  void _refreshSubscriptionStatus() {
    setState(() {
      _premiumStatusFuture = _entitlements.isPremium();
    });
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

  Future<void> _handleSubscriptionTap() async {
    try {
      final hasPremium = await _entitlements.isPremium();
      if (!mounted) return;
      if (!hasPremium) {
        final purchased = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => PaywallModal(trigger: 'settings'),
        );
        if (purchased == true) {
          _refreshSubscriptionStatus();
        }
        return;
      }

      final Uri url = Uri.parse('https://play.google.com/store/account/subscriptions');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('No pudimos abrir Google Play.');
      }
    } catch (error) {
      _showSnackBar('Error al verificar tu suscripcion: $error');
    }
  }

  Future<void> _handleRestorePurchases() async {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await _entitlements.restorePurchases();
      _refreshSubscriptionStatus();
      _showSnackBar('Compras restauradas correctamente.');
    } on PurchaseException catch (error) {
      _showSnackBar(error.message);
    } catch (error) {
      _showSnackBar('Error al restaurar compras: $error');
    } finally {
      if (navigator.canPop()) {
        navigator.pop();
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final languageCode = _resolvedLanguage(context);
    final languageSubtitle = languageCode == 'es'
        ? l10n.settingsLanguageSpanish
        : l10n.settingsLanguageEnglish;
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
            child: Text(
              'Suscripcion',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.card_membership_outlined),
                  title: const Text('Suscripcion Premium'),
                  subtitle: FutureBuilder<bool>(
                    future: _premiumStatusFuture ?? _entitlements.isPremium(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Verificando estado...');
                      }
                      if (snapshot.data == true) {
                        return const Text('Activa - Administrar en Google Play');
                      }
                      return const Text('No activa - toca para suscribirte');
                    },
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _handleSubscriptionTap,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore_outlined),
                  title: const Text('Restaurar compras'),
                  subtitle: const Text('Si ya compraste Premium en otro dispositivo'),
                  onTap: _handleRestorePurchases,
                ),
              ],
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
