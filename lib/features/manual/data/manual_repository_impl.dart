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

  domain.Tag _rowToTag(Tag row) =>
      domain.Tag(id: row.id, name: row.name, createdAt: row.createdAt);

  domain.Manual _rowToManual(
    Manual row,
    List<domain.Step> steps,
    List<domain.Tag> tags,
    List<String> tagIds,
  ) {
    return domain.Manual(
      id: row.id,
      title: row.title,
      coverImagePath: row.coverImagePath,
      isFavorite: row.isFavorite,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      sortKey: row.sortKey,
      tagIds: tagIds,
      tags: tags,
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
      createdAt: row.createdAt,
      completedAt: row.completedAt,
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

  Future<(List<domain.Tag>, List<String>)> _loadTagsForManual(
      String manualId) async {
    final join = db.select(db.manualTags).join([
      innerJoin(db.tags, db.tags.id.equalsExp(db.manualTags.tagId)),
    ])
      ..where(db.manualTags.manualId.equals(manualId));
    final rows = await join.get();
    final tagIds = <String>[];
    final tagMap = <String, domain.Tag>{};
    for (final r in rows) {
      final t = _rowToTag(r.readTable(db.tags));
      tagIds.add(t.id);
      tagMap[t.id] = t;
    }
    return (tagMap.values.toList(), tagIds);
  }

  @override
  Future<List<domain.Manual>> listManuals() async {
    final manualRows = await db.select(db.manuals).get();
    final result = <domain.Manual>[];
    for (final r in manualRows) {
      final steps = await _loadStepsForManual(r.id);
      final (tags, tagIds) = await _loadTagsForManual(r.id);
      result.add(_rowToManual(r, steps, tags, tagIds));
    }
    return result;
  }

  @override
  Future<domain.Manual?> getManual(String id) async {
    final row = await (db.select(db.manuals)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    final steps = await _loadStepsForManual(id);
    final (tags, tagIds) = await _loadTagsForManual(id);
    return _rowToManual(row, steps, tags, tagIds);
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
              sortKey: Value(manual.sortKey),
            ),
          );

      // 重置 tag 关联
      await (db.delete(db.manualTags)
            ..where((mt) => mt.manualId.equals(manual.id)))
          .go();
      for (final tagId in manual.tagIds) {
        await db.into(db.manualTags).insert(
              ManualTagsCompanion.insert(manualId: manual.id, tagId: tagId),
              mode: InsertMode.insertOrIgnore,
            );
      }

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
                createdAt: s.createdAt,
                completedAt: Value(s.completedAt),
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

  // --- Tag CRUD ---

  @override
  Future<List<domain.Tag>> listTags() async {
    final rows = await (db.select(db.tags)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();
    return rows.map(_rowToTag).toList();
  }

  @override
  Future<void> saveTag(domain.Tag tag) async {
    await db.into(db.tags).insertOnConflictUpdate(
          TagsCompanion.insert(
            id: tag.id,
            name: tag.name,
            createdAt: tag.createdAt,
          ),
        );
  }

  @override
  Future<void> deleteTag(String id) async {
    await (db.delete(db.manualTags)..where((mt) => mt.tagId.equals(id))).go();
    await (db.delete(db.tags)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> setManualTags(String manualId, Set<String> tagIds) async {
    await db.transaction(() async {
      await (db.delete(db.manualTags)
            ..where((mt) => mt.manualId.equals(manualId)))
          .go();
      for (final tagId in tagIds) {
        await db.into(db.manualTags).insert(
              ManualTagsCompanion.insert(manualId: manualId, tagId: tagId),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }
}