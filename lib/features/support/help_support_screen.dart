import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:edaptia/l10n/app_localizations.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  static const routeName = '/help-support';

  static final Uri _telegramChannelUri =
      Uri.parse('https://t.me/edaptia_news');
  static final Uri _telegramGroupUri =
      Uri.parse('https://t.me/adaptia_club');
  static final Uri _privacyUri = Uri.parse('https://adaptia.io/privacy');
  static final Uri _termsUri = Uri.parse('https://adaptia.io/terms');
  static final Future<_SupportContext> _supportContextFuture =
      _loadSupportContext();

  static Future<_SupportContext> _loadSupportContext() async {
    final info = await PackageInfo.fromPlatform();
    return _SupportContext(
      appName: info.appName,
      version: info.version,
      buildNumber: info.buildNumber,
    );
  }

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpSupportTitle),
      ),
      body: FutureBuilder<_SupportContext>(
        future: HelpSupportScreen._supportContextFuture,
        builder: (context, snapshot) {
          final supportContext = snapshot.data;
          final versionLabel = supportContext?.versionLabel ?? '...';
          final deviceLabel = _deviceLabel();

          final faqItems = _buildFaqItems(l10n);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                l10n.helpSupportSubtitle,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: l10n.helpContactSectionTitle),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SupportTile(
                      icon: Icons.mail_outline,
                      label: l10n.helpContactSpanish,
                      description: l10n.helpContactSpanishDescription,
                      onTap: () async {
                        final info = await HelpSupportScreen._supportContextFuture;
                        if (!context.mounted) return;
                        final subject = l10n.helpEmailSubject(
                          info.appName,
                          info.versionLabel,
                          deviceLabel,
                        );
                        final uri = _buildMailUri(
                          address: 'soporte@edaptia.io',
                          subject: subject,
                        );
                        await _launchUri(context, uri, l10n);
                      },
                    ),
                    const Divider(height: 1),
                    _SupportTile(
                      icon: Icons.alternate_email_outlined,
                      label: l10n.helpContactEnglish,
                      description: l10n.helpContactEnglishDescription,
                      onTap: () async {
                        final info = await HelpSupportScreen._supportContextFuture;
                        if (!context.mounted) return;
                        final subject = l10n.helpEmailSubject(
                          info.appName,
                          info.versionLabel,
                          deviceLabel,
                        );
                        final uri = _buildMailUri(
                          address: 'help@edaptia.io',
                          subject: subject,
                        );
                        await _launchUri(context, uri, l10n);
                      },
                    ),
                    const Divider(height: 1),
                    _SupportTile(
                      icon: Icons.bug_report_outlined,
                      label: l10n.helpReportBug,
                      description: l10n.helpReportBugDescription,
                      onTap: () async {
                        final info = await HelpSupportScreen._supportContextFuture;
                        if (!context.mounted) return;
                        final localeTag =
                            Localizations.localeOf(context).toLanguageTag();
                        final timestamp = DateTime.now()
                            .toUtc()
                            .toIso8601String();
                        final subject = l10n.helpBugReportSubject(
                          info.appName,
                          info.versionLabel,
                          deviceLabel,
                        );
                        final body = l10n.helpBugReportBody(
                          timestamp,
                          localeTag,
                          info.versionLabel,
                          deviceLabel,
                        );
                        final uri = _buildMailUri(
                          address: 'soporte@edaptia.io',
                          subject: subject,
                          body: body,
                        );
                        await _launchUri(context, uri, l10n);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: l10n.helpCommunitySectionTitle),
              Card(
                margin: EdgeInsets.zero,
                child: _SupportTile(
                  icon: Icons.groups_outlined,
                  label: l10n.helpJoinCommunity,
                  description: l10n.helpJoinCommunityDescription,
                  onTap: () => _showCommunitySheet(context, l10n),
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: l10n.helpFaqSectionTitle),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var index = 0; index < faqItems.length; index++)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ExpansionTile(
                            key: ValueKey(faqItems[index].question),
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: Text(
                              faqItems[index].question,
                              style: theme.textTheme.titleMedium,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    faqItems[index].answer,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (index < faqItems.length - 1)
                            const Divider(height: 1),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: l10n.helpAboutTitle),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(l10n.helpAboutDescription),
                      subtitle: Text(l10n.helpAboutVersion(versionLabel)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: Text(l10n.helpPrivacyPolicy),
                      onTap: () =>
                          _launchUri(context, HelpSupportScreen._privacyUri, l10n),
                      trailing: const Icon(Icons.open_in_new),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.gavel_outlined),
                      title: Text(l10n.helpTermsOfService),
                      onTap: () => _launchUri(context, HelpSupportScreen._termsUri, l10n),
                      trailing: const Icon(Icons.open_in_new),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _deviceLabel() {
    final base = defaultTargetPlatform.name;
    if (kIsWeb) {
      return 'web-$base';
    }
    return base;
  }

  List<_FaqItem> _buildFaqItems(AppLocalizations l10n) {
    return [
      _FaqItem(
        question: l10n.helpFaqQuestion1,
        answer: l10n.helpFaqAnswer1,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion2,
        answer: l10n.helpFaqAnswer2,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion3,
        answer: l10n.helpFaqAnswer3,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion4,
        answer: l10n.helpFaqAnswer4,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion5,
        answer: l10n.helpFaqAnswer5,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion6,
        answer: l10n.helpFaqAnswer6,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion7,
        answer: l10n.helpFaqAnswer7,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion8,
        answer: l10n.helpFaqAnswer8,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion9,
        answer: l10n.helpFaqAnswer9,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion10,
        answer: l10n.helpFaqAnswer10,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion11,
        answer: l10n.helpFaqAnswer11,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion12,
        answer: l10n.helpFaqAnswer12,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion13,
        answer: l10n.helpFaqAnswer13,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion14,
        answer: l10n.helpFaqAnswer14,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion15,
        answer: l10n.helpFaqAnswer15,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion16,
        answer: l10n.helpFaqAnswer16,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion17,
        answer: l10n.helpFaqAnswer17,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion18,
        answer: l10n.helpFaqAnswer18,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion19,
        answer: l10n.helpFaqAnswer19,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion20,
        answer: l10n.helpFaqAnswer20,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion21,
        answer: l10n.helpFaqAnswer21,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion22,
        answer: l10n.helpFaqAnswer22,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion23,
        answer: l10n.helpFaqAnswer23,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion24,
        answer: l10n.helpFaqAnswer24,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion25,
        answer: l10n.helpFaqAnswer25,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion26,
        answer: l10n.helpFaqAnswer26,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion27,
        answer: l10n.helpFaqAnswer27,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion28,
        answer: l10n.helpFaqAnswer28,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion29,
        answer: l10n.helpFaqAnswer29,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion30,
        answer: l10n.helpFaqAnswer30,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion31,
        answer: l10n.helpFaqAnswer31,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion32,
        answer: l10n.helpFaqAnswer32,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion33,
        answer: l10n.helpFaqAnswer33,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion34,
        answer: l10n.helpFaqAnswer34,
      ),
      _FaqItem(
        question: l10n.helpFaqQuestion35,
        answer: l10n.helpFaqAnswer35,
      ),
    ];
  }

  Uri _buildMailUri({
    required String address,
    required String subject,
    String? body,
  }) {
    final query = <String, String>{
      'subject': subject,
      if (body != null) 'body': body,
    };
    return Uri(
      scheme: 'mailto',
      path: address,
      query: Uri(queryParameters: query).query,
    );
  }

  Future<void> _launchUri(
    BuildContext context,
    Uri uri,
    AppLocalizations l10n,
  ) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.helpLaunchError)),
      );
    }
  }

  Future<void> _showCommunitySheet(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: Text(l10n.helpJoinCommunityChannel),
                subtitle: Text(HelpSupportScreen._telegramChannelUri.toString()),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _launchUri(context, HelpSupportScreen._telegramChannelUri, l10n);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.forum_outlined),
                title: Text(l10n.helpJoinCommunityGroup),
                subtitle: Text(HelpSupportScreen._telegramGroupUri.toString()),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _launchUri(context, HelpSupportScreen._telegramGroupUri, l10n);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SupportContext {
  const _SupportContext({
    required this.appName,
    required this.version,
    required this.buildNumber,
  });

  final String appName;
  final String version;
  final String buildNumber;

  String get versionLabel => '$version+$buildNumber';
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        description,
        style: theme.textTheme.bodySmall,
      ),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}




