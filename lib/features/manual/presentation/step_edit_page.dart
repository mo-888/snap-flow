import 'package:flutter/material.dart';

class StepEditPage extends StatelessWidget {
  final String manualId;
  final String stepId;
  const StepEditPage({super.key, required this.manualId, required this.stepId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('编辑步骤')),
      body: Center(child: Text('Step: $stepId (in $manualId)')),
    );
  }
}