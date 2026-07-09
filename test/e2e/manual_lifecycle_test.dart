// test/e2e/manual_lifecycle_test.dart
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:snapflow/core/db/database.dart' hide Manual, Step, StepImage;
import 'package:snapflow/core/files/file_service.dart';
import 'package:snapflow/features/export/pdf_exporter.dart';
import 'package:snapflow/features/manual/data/manual_repository_impl.dart';
import 'package:snapflow/features/manual/domain/entities.dart';
import 'package:image/image.dart' as img;

void main() {
  test('create → add step → add image → export PDF lifecycle', () async {
    final tempRoot = await Directory.systemTemp.createTemp('snapflow_e2e_');
    final db = AppDatabase(NativeDatabase.memory());
    final fs = FileService(root: tempRoot.path);
    await fs.init();
    final repo = ManualRepositoryImpl(db: db, files: fs);

    final now = DateTime(2026, 1, 1);
    final m = Manual(
      id: 'm1',
      title: 'E2E',
      coverImagePath: null,
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
      steps: const [],
    );
    await repo.saveManual(m);

    final step = Step(
      id: 's1',
      order: 100,
      title: 'Do thing',
      note: 'Carefully',
      completed: false,
      images: const [],
      optionalFields: const {},
    createdAt: DateTime(2026, 1, 1),
    );
    await repo.saveManual(m.copyWith(steps: [step]));

    final srcBytes = img.encodeJpg(img.Image(width: 8, height: 8));
    final src = File('${tempRoot.path}/src.jpg')..writeAsBytesSync(srcBytes);
    final original = await fs.copyOriginal('m1', src);
    final thumb = await fs.saveThumbnail('m1', 'i1', List.filled(32, 100));
    final stepImage = StepImage(
      id: 'i1',
      order: 100,
      originalPath: original,
      editedPath: null,
      thumbnailPath: thumb,
    );
    await repo.saveManual(m.copyWith(
      steps: [step.copyWith(images: [stepImage])],
      updatedAt: DateTime.now(),
    ));

    final loaded = await repo.getManual('m1');
    expect(loaded, isNotNull);
    expect(loaded!.steps.length, 1);
    expect(loaded.steps.first.images.length, 1);
    expect(loaded.steps.first.images.first.originalPath, original);

    final pdf = await PdfExporter(
      fontProvider: () async => pw.Font.helvetica(),
    ).exportToBytes(loaded);
    expect(pdf.length, greaterThan(100));
    expect(String.fromCharCodes(pdf.take(4)), equals('%PDF'));

    await db.close();
    await tempRoot.delete(recursive: true);
  });
}
