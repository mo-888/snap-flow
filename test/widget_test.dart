import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/app.dart';

void main() {
  testWidgets('App boots and shows title', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SnapFlowApp()));
    expect(find.byType(SnapFlowApp), findsOneWidget);
  });
}
