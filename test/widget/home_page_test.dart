import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/features/manual/domain/entities.dart';
import 'package:snapflow/features/manual/domain/manual_repository.dart';
import 'package:snapflow/features/manual/presentation/home_page.dart';
import 'package:snapflow/shared/providers.dart';
import 'package:snapflow/core/theme.dart';

class _StubRepo implements ManualRepository {
  final List<Manual> manuals;
  final List<String> deletedIds = [];
  _StubRepo(this.manuals);

  @override
  Future<List<Manual>> listManuals() async =>
      manuals.where((m) => !deletedIds.contains(m.id)).toList();
  @override
  Future<Manual?> getManual(String id) async =>
      manuals.where((m) => m.id == id).cast<Manual?>().firstOrNull;
  @override
  Future<void> saveManual(Manual manual) async {}
  @override
  Future<void> deleteManual(String id) async => deletedIds.add(id);
  @override
  Future<List<Tag>> listTags() async => [];
  @override
  Future<void> saveTag(Tag tag) async {}
  @override
  Future<void> deleteTag(String id) async {}
  @override
  Future<void> setManualTags(String manualId, Set<String> tagIds) async {}
}

Manual _stub(String id, String title, int steps) => Manual(
      id: id,
      title: title,
      coverImagePath: null,
      isFavorite: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      steps: List.generate(
        steps,
        (i) => Step(
          id: '$id-s$i',
          order: i * 100,
          title: 'Step $i',
          note: '',
          completed: false,
          images: const [],
          optionalFields: const {},
          createdAt: DateTime(2026, 1, 1),
        ),
      ),
    );

void main() {
  testWidgets('Home shows empty state when no manuals', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manualRepositoryProvider.overrideWith((_) async => _StubRepo([])),
        ],
        child: MaterialApp(theme: SnapFlowTheme.light(), home: const HomePage()),
      ),
    );
    await tester.pump();
    expect(find.textContaining('没有匹配的手册'), findsOneWidget);
  });

  testWidgets('Home renders manual cards', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manualRepositoryProvider.overrideWith((_) async => _StubRepo([_stub('m1', '巡检SOP', 3)])),
        ],
        child: MaterialApp(theme: SnapFlowTheme.light(), home: const HomePage()),
      ),
    );
    await tester.pump();
    expect(find.text('巡检SOP'), findsOneWidget);
    expect(find.textContaining('3 步'), findsOneWidget);
  });

  testWidgets('Swipe manual card, confirm, deletes and refreshes list', (tester) async {
    final repo = _StubRepo([_stub('m1', '巡检SOP', 3)]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manualRepositoryProvider.overrideWith((_) async => repo),
        ],
        child: MaterialApp(theme: SnapFlowTheme.light(), home: const HomePage()),
      ),
    );
    await tester.pump();
    expect(find.text('巡检SOP'), findsOneWidget);

    await tester.drag(find.text('巡检SOP'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('删除手册？'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(repo.deletedIds, contains('m1'));
    expect(find.text('巡检SOP'), findsNothing);
    // SnapToast schedules a 2400ms Timer; drain it so the test framework
    // doesn't complain about a pending Timer on dispose.
    await tester.binding.delayed(const Duration(milliseconds: 2500));
  });
}