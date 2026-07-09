import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/features/manual/domain/entities.dart';
import 'package:snapflow/features/manual/domain/manual_repository.dart';
import 'package:snapflow/features/manual/presentation/step_edit_page.dart';
import 'package:snapflow/shared/providers.dart';

class _StubRepo implements ManualRepository {
  final Manual m;
  _StubRepo(this.m);
  @override
  Future<List<Manual>> listManuals() async => [m];
  @override
  Future<Manual?> getManual(String id) async => m.id == id ? m : null;
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
  testWidgets('StepEditPage shows title field with current value', (tester) async {
    final m = Manual(
      id: 'm1',
      title: 'M',
      coverImagePath: null,
      isFavorite: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      steps: [
        Step(
          id: 's1',
          order: 100,
          title: '原标题',
          note: '原说明',
          completed: false,
          images: [],
          optionalFields: {},
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manualRepositoryProvider.overrideWith((_) async => _StubRepo(m)),
        ],
        child: const MaterialApp(home: StepEditPage(manualId: 'm1', stepId: 's1')),
      ),
    );
    await tester.pump();
    expect(find.text('原标题'), findsOneWidget);
    expect(find.text('原说明'), findsOneWidget);
  });
}