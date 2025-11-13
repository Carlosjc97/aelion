import 'package:flutter/material.dart';

/// Onboarding gate screen - Placeholder for future onboarding flow
class OnboardingGate extends StatelessWidget {
  const OnboardingGate({super.key});

  static const routeName = '/onboarding-gate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: const Center(
        child: Text('Onboarding flow coming soon'),
      ),
    );
  }
}
