import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/features/manual/domain/entities.dart' as domain;
import 'package:snapflow/features/manual/domain/manual_repository.dart';
import 'package:snapflow/features/manual/presentation/manual_detail_page.dart';
import 'package:snapflow/shared/providers.dart';

class _StubRepo implements ManualRepository {
  final domain.Manual m;
  _StubRepo(this.m);

  @override
  Future<List<domain.Manual>> listManuals() async => [m];
  @override
  Future<domain.Manual?> getManual(String id) async => m.id == id ? m : null;
  @override
  Future<void> saveManual(domain.Manual manual) async {}
  @override
  Future<void> deleteManual(String id) async {}
}

domain.Manual _make() => domain.Manual(
      id: 'm1',
      title: 'Test',
      coverImagePath: null,
      isFavorite: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      steps: [
        domain.Step(id: 's1', order: 100, title: '第一步', note: 'note1', completed: false, images: const [], optionalFields: const {}),
        domain.Step(id: 's2', order: 200, title: '第二步', note: 'note2', completed: false, images: const [], optionalFields: const {}),
      ],
    );

void main() {
  testWidgets('Detail shows step titles', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manualRepositoryProvider.overrideWith((_) async => _StubRepo(_make())),
        ],
        child: const MaterialApp(home: ManualDetailPage(manualId: 'm1')),
      ),
    );
    await tester.pump();
    expect(find.text('第一步'), findsOneWidget);
    expect(find.text('第二步'), findsOneWidget);
  });
}