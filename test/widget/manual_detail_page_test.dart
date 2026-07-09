import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/core/theme.dart';
import 'package:snapflow/features/manual/domain/entities.dart' as domain;
import 'package:snapflow/features/manual/domain/entities.dart' show Tag;
import 'package:snapflow/features/manual/domain/manual_repository.dart';
import 'package:snapflow/features/manual/presentation/manual_detail_page.dart';
import 'package:snapflow/shared/providers.dart';

class _StubRepo implements ManualRepository {
  final List<domain.Manual> _manuals;
  domain.Manual? lastSaved;
  _StubRepo(domain.Manual m) : _manuals = [m];

  @override
  Future<List<domain.Manual>> listManuals() async => List.unmodifiable(_manuals);
  @override
  Future<domain.Manual?> getManual(String id) async {
    for (final m in _manuals) {
      if (m.id == id) return m;
    }
    return null;
  }
  @override
  Future<void> saveManual(domain.Manual manual) async {
    lastSaved = manual;
    final idx = _manuals.indexWhere((m) => m.id == manual.id);
    if (idx >= 0) {
      _manuals[idx] = manual;
    } else {
      _manuals.add(manual);
    }
  }
  @override
  Future<void> deleteManual(String id) async {}
  @override
  Future<List<Tag>> listTags() async => [];
  @override
  Future<void> saveTag(Tag tag) async {}
  @override
  Future<void> deleteTag(String id) async {}
}

domain.Manual _make() => domain.Manual(
      id: 'm1',
      title: 'Test',
      coverImagePath: null,
      isFavorite: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      steps: [
        domain.Step(id: 's1', order: 100, title: '第一步', note: 'note1', completed: false, images: const [], optionalFields: const {}, createdAt: DateTime(2026, 1, 1)),
        domain.Step(id: 's2', order: 200, title: '第二步', note: 'note2', completed: false, images: const [], optionalFields: const {}, createdAt: DateTime(2026, 1, 1)),
      ],
    );

void main() {
  testWidgets('Detail shows step titles', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manualRepositoryProvider.overrideWith((_) async => _StubRepo(_make())),
        ],
        child: MaterialApp(
          theme: SnapFlowTheme.light(),
          home: const ManualDetailPage(manualId: 'm1'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('第一步', skipOffstage: false), findsOneWidget);
    expect(find.text('第二步', skipOffstage: false), findsOneWidget);
  });

  testWidgets('duplicate step creates new step with same fields', (tester) async {
    final baseStep = domain.Step(
      id: 's-orig', order: 200,
      title: '原标题', note: '原说明',
      completed: true, images: const [
        domain.StepImage(id: 'img-1', order: 0, originalPath: '/tmp/a.jpg', editedPath: null, thumbnailPath: '/tmp/a.thumb.jpg'),
      ],
      optionalFields: const {'电压': '380V'},
      createdAt: DateTime(2026, 1, 1),
      completedAt: DateTime(2026, 1, 2),
    );
    final m = domain.Manual(
      id: 'm1', title: 'M', coverImagePath: null, isFavorite: false,
      createdAt: DateTime(2026, 1, 1), updatedAt: DateTime(2026, 1, 1),
      steps: [baseStep],
    );
    final stub = _StubRepo(m);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [manualRepositoryProvider.overrideWith((_) async => stub)],
        child: MaterialApp(
          theme: SnapFlowTheme.light(),
          home: const ManualDetailPage(manualId: 'm1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('原标题'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('复制'));
    await tester.pumpAndSettle();

    expect(find.text('原标题'), findsNWidgets(2));
    final saved = stub.lastSaved;
    expect(saved, isNotNull);
    expect(saved!.steps.length, 2);
    final dup = saved.steps.firstWhere((st) => st.id != 's-orig');
    expect(dup.id, isNot(equals('s-orig')));
    expect(dup.completed, isFalse);
    expect(dup.completedAt, isNull);
    expect(dup.title, '原标题');
    expect(dup.note, '原说明');
    expect(dup.images.length, 1);
    expect(dup.images.first.id, isNot(equals('img-1')));
    expect(dup.order, greaterThan(200));
    // SnapToast schedules a 2400ms Timer; drain it via the fake-async clock
    // so the test framework doesn't complain about a pending Timer on dispose.
    await tester.binding.delayed(const Duration(milliseconds: 2500));
  });
}