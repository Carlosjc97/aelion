import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  static final Uri _privacyPolicyUri =
      Uri.parse('https://aelion-c90d2.web.app/privacy-policy.html');
  static final Uri _termsOfServiceUri =
      Uri.parse('https://aelion-c90d2.web.app/terms-of-service.html');

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
    final l10n = AppLocalizations.of(context)!;
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
        _showSnackBar(l10n.helpLaunchError);
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

  Future<void> _openExternalLink(Uri url, AppLocalizations l10n) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar(l10n.helpLaunchError);
    }
  }

  Future<void> _showReportContentDialog() async {
    bool offensiveContent = false;
    bool incorrectInfo = false;
    final textController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.flag_outlined, color: Colors.orange),
                SizedBox(width: 8),
                Text('Reportar contenido'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona el tipo de problema:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Contenido ofensivo'),
                    value: offensiveContent,
                    onChanged: (value) => setState(() => offensiveContent = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Información incorrecta'),
                    value: incorrectInfo,
                    onChanged: (value) => setState(() => incorrectInfo = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Detalles (opcional)',
                      hintText: 'Describe el problema...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Enviar reporte'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && mounted) {
      // Save report to Firestore
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('content_reports').add({
            'userId': user.uid,
            'offensiveContent': offensiveContent,
            'incorrectInfo': incorrectInfo,
            'details': textController.text.trim(),
            'timestamp': FieldValue.serverTimestamp(),
            'source': 'settings',
          });
          _showSnackBar('Reporte enviado. Gracias por tu colaboración.');
        }
      } catch (error) {
        _showSnackBar('Error al enviar el reporte');
      }
    }
    textController.dispose();
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
              'Suscripción',
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
                  title: const Text('Suscripción Premium'),
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
          const SizedBox(height: 16),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.settingsPrivacyPolicy),
                  subtitle: Text(
                    l10n.settingsPrivacyPolicySubtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 20),
                  onTap: () => _openExternalLink(_privacyPolicyUri, l10n),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined),
                  title: Text(l10n.settingsTermsOfService),
                  subtitle: Text(
                    l10n.settingsTermsOfServiceSubtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 20),
                  onTap: () => _openExternalLink(_termsOfServiceUri, l10n),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SettingsTile(
                  icon: Icons.support_agent_outlined,
                  title: l10n.settingsHelpSupport,
                  subtitle: l10n.settingsHelpSupportSubtitle,
                  onTap: () {
                    Navigator.of(context).pushNamed(HelpSupportScreen.routeName);
                  },
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.flag_outlined,
                  title: 'Reportar contenido',
                  subtitle: 'Reportar contenido ofensivo o información incorrecta',
                  onTap: _showReportContentDialog,
                ),
              ],
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
