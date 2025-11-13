import 'package:flutter/material.dart';

/// Onboarding gate screen - Placeholder for future onboarding flow
class OnboardingGate extends StatelessWidget {
  const OnboardingGate({super.key, this.child});

  static const routeName = '/onboarding-gate';
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // If child is provided, show it directly (skip onboarding for now)
    if (child != null) {
      return child!;
    }

    // Otherwise show placeholder onboarding screen
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
