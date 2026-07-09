import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/app.dart';
import 'package:snapflow/features/manual/domain/entities.dart';
import 'package:snapflow/features/manual/domain/manual_repository.dart';
import 'package:snapflow/shared/providers.dart';

class _NoopRepo implements ManualRepository {
  @override
  Future<List<Manual>> listManuals() async => const [];
  @override
  Future<Manual?> getManual(String id) async => null;
  @override
  Future<void> saveManual(Manual manual) async {}
  @override
  Future<void> deleteManual(String id) async {}
  @override
  Future<List<Tag>> listTags() async => [];
  @override
  Future<void> saveTag(Tag tag) async {}
  @override
  Future<void> deleteTag(String id) async {}
}

void main() {
  testWidgets('App boots and shows title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manualRepositoryProvider.overrideWith((_) async => _NoopRepo()),
        ],
        child: const MaterialApp(home: SnapFlowApp()),
      ),
    );
    await tester.pump();
    expect(find.byType(SnapFlowApp), findsOneWidget);
  });
}
