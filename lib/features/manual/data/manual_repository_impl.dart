import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/files/file_service.dart';
import '../domain/entities.dart' as domain;
import '../domain/manual_repository.dart';

class ManualRepositoryImpl implements ManualRepository {
  final AppDatabase db;
  final FileService files;

  ManualRepositoryImpl({required this.db, required this.files});

  domain.Manual _rowToManual(Manual row, List<domain.Step> steps) {
    return domain.Manual(
      id: row.id,
      title: row.title,
      coverImagePath: row.coverImagePath,
      isFavorite: row.isFavorite,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      steps: steps,
    );
  }

  domain.Step _rowToStep(Step row, List<domain.StepImage> images) {
    return domain.Step(
      id: row.id,
      order: row.order,
      title: row.title,
      note: row.note,
      completed: row.completed,
      images: images,
      optionalFields:
          Map<String, String>.from(jsonDecode(row.optionalFieldsJson)),
    );
  }

  domain.StepImage _rowToImage(StepImage row) {
    return domain.StepImage(
      id: row.id,
      order: row.order,
      originalPath: row.originalPath,
      editedPath: row.editedPath,
      thumbnailPath: row.thumbnailPath,
    );
  }

  Future<List<domain.Step>> _loadStepsForManual(String manualId) async {
    final stepRows = await (db.select(db.steps)
          ..where((s) => s.manualId.equals(manualId))
          ..orderBy([(s) => OrderingTerm(expression: s.order)]))
        .get();
    final result = <domain.Step>[];
    for (final s in stepRows) {
      final images = await (db.select(db.stepImages)
            ..where((i) => i.stepId.equals(s.id))
            ..orderBy([(i) => OrderingTerm(expression: i.order)]))
          .get();
      result.add(_rowToStep(s, images.map(_rowToImage).toList()));
    }
    return result;
  }

  @override
  Future<List<domain.Manual>> listManuals() async {
    final manualRows = await db.select(db.manuals).get();
    final result = <domain.Manual>[];
    for (final r in manualRows) {
      final steps = await _loadStepsForManual(r.id);
      result.add(_rowToManual(r, steps));
    }
    return result;
  }

  @override
  Future<domain.Manual?> getManual(String id) async {
    final row = await (db.select(db.manuals)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    final steps = await _loadStepsForManual(id);
    return _rowToManual(row, steps);
  }

  @override
  Future<void> saveManual(domain.Manual manual) async {
    await db.transaction(() async {
      await db.into(db.manuals).insertOnConflictUpdate(
            ManualsCompanion.insert(
              id: manual.id,
              title: Value(manual.title),
              coverImagePath: Value(manual.coverImagePath),
              isFavorite: Value(manual.isFavorite),
              createdAt: manual.createdAt,
              updatedAt: manual.updatedAt,
            ),
          );

      final existingSteps = await (db.select(db.steps)
            ..where((s) => s.manualId.equals(manual.id)))
          .get();
      final keepIds = manual.steps.map((s) => s.id).toSet();
      for (final es in existingSteps) {
        if (!keepIds.contains(es.id)) {
          await (db.delete(db.steps)..where((s) => s.id.equals(es.id))).go();
        }
      }
      for (final s in manual.steps) {
        await db.into(db.steps).insertOnConflictUpdate(
              StepsCompanion.insert(
                id: s.id,
                manualId: manual.id,
                order: s.order,
                title: Value(s.title),
                note: Value(s.note),
                completed: Value(s.completed),
                optionalFieldsJson: Value(jsonEncode(s.optionalFields)),
              ),
            );

        final existingImages = await (db.select(db.stepImages)
              ..where((i) => i.stepId.equals(s.id)))
          .get();
        final keepImgIds = s.images.map((i) => i.id).toSet();
        for (final ei in existingImages) {
          if (!keepImgIds.contains(ei.id)) {
            await (db.delete(db.stepImages)..where((i) => i.id.equals(ei.id)))
                .go();
          }
        }
        for (final img in s.images) {
          await db.into(db.stepImages).insertOnConflictUpdate(
                StepImagesCompanion.insert(
                  id: img.id,
                  stepId: s.id,
                  order: img.order,
                  originalPath: img.originalPath,
                  editedPath: Value(img.editedPath),
                  thumbnailPath: img.thumbnailPath,
                ),
              );
        }
      }
    });
  }

  @override
  Future<void> deleteManual(String id) async {
    await (db.delete(db.manuals)..where((m) => m.id.equals(id))).go();
    await files.deleteManualImages(id);
  }
}
