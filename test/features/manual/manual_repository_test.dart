import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/features/manual/domain/entities.dart';
import 'package:snapflow/features/manual/domain/manual_repository.dart';

class _FakeRepo implements ManualRepository {
  final List<Manual> _store = [];

  @override
  Future<List<Manual>> listManuals() async => List.unmodifiable(_store);

  @override
  Future<Manual?> getManual(String id) async =>
      _store.where((m) => m.id == id).cast<Manual?>().firstOrNull;

  @override
  Future<void> saveManual(Manual manual) async {
    _store.removeWhere((m) => m.id == manual.id);
    _store.add(manual);
  }

  @override
  Future<void> deleteManual(String id) async {
    _store.removeWhere((m) => m.id == id);
  }

  @override
  Future<List<Tag>> listTags() async => const [];

  @override
  Future<void> saveTag(Tag tag) async {}

  @override
  Future<void> deleteTag(String id) async {}
  @override
  Future<void> setManualTags(String manualId, Set<String> tagIds) async {}
}

void main() {
  test('Repository save/load round-trip', () async {
    final repo = _FakeRepo();
    final m = Manual(
      id: 'm1',
      title: 'Test',
      coverImagePath: null,
      isFavorite: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      steps: const [],
    );
    await repo.saveManual(m);
    final loaded = await repo.getManual('m1');
    expect(loaded, isNotNull);
    expect(loaded!.title, 'Test');
    expect(loaded.isFavorite, isFalse);
  });

  test('deleteManual removes by id', () async {
    final repo = _FakeRepo();
    await repo.saveManual(Manual(
      id: 'm2',
      title: 'X',
      coverImagePath: null,
      isFavorite: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      steps: const [],
    ));
    await repo.deleteManual('m2');
    expect(await repo.getManual('m2'), isNull);
    expect(await repo.listManuals(), isEmpty);
  });
}