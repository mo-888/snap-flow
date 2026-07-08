import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/manual/presentation/home_page.dart';

class SnapFlowApp extends StatelessWidget {
  const SnapFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapFlow',
      theme: SnapFlowTheme.light(),
      darkTheme: SnapFlowTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
