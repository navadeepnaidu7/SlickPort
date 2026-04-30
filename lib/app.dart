import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

class SlickPortApp extends StatelessWidget {
  const SlickPortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SlickPort',
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}
