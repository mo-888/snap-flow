// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/core/db/database.dart';
import 'package:snapflow/core/files/file_service.dart';
import 'package:snapflow/features/manual/data/manual_repository_impl.dart';
import 'package:snapflow/features/manual/domain/entities.dart' as domain;

void main() {
  late Directory tempRoot;
  late AppDatabase db;
  late ManualRepositoryImpl repo;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('snapflow_repo_');
    db = AppDatabase(NativeDatabase.memory());
    final fs = FileService(root: tempRoot.path);
    await fs.init();
    repo = ManualRepositoryImpl(db: db, files: fs);
  });

  tearDown(() async {
    await db.close();
    if (tempRoot.existsSync()) await tempRoot.delete(recursive: true);
  });

  test('saveManual persists and listManuals returns it', () async {
    final m = domain.Manual(
      id: 'm1',
      title: 'X',
      coverImagePath: null,
      isFavorite: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      steps: const [],
    );
    await repo.saveManual(m);
    final list = await repo.listManuals();
    expect(list.length, 1);
    expect(list.first.title, 'X');
  });

  test('deleteManual removes row', () async {
    final m = domain.Manual(
      id: 'm1',
      title: 'X',
      coverImagePath: null,
      isFavorite: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      steps: const [],
    );
    await repo.saveManual(m);
    await repo.deleteManual('m1');
    final list = await repo.listManuals();
    expect(list, isEmpty);
  });

  test('saveManual with steps persists nested steps and images', () async {
    final m = domain.Manual(
      id: 'm1',
      title: 'X',
      coverImagePath: null,
      isFavorite: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      steps: [
        domain.Step(
          id: 's1',
          order: 100,
          title: 'Step 1',
          note: 'do it',
          completed: false,
          images: [
            domain.StepImage(
              id: 'i1',
              order: 100,
              originalPath: '/tmp/orig.jpg',
              editedPath: null,
              thumbnailPath: '/tmp/thumb.jpg',
            ),
          ],
          optionalFields: {'param1': 'val1'},
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    );
    await repo.saveManual(m);
    final loaded = await repo.getManual('m1');
    expect(loaded, isNotNull);
    expect(loaded!.steps.length, 1);
    expect(loaded.steps.first.images.length, 1);
    expect(loaded.steps.first.images.first.originalPath, '/tmp/orig.jpg');
    expect(loaded.steps.first.optionalFields['param1'], 'val1');
  });
}
