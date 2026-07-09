import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../manual/domain/entities.dart' as domain;
import '../../manual/domain/manual_repository.dart';

/// 手册 JSON 导入。导入时为所有 id 重新生成，避免与本地数据冲突；图片以 base64 落盘到本地存储。
class ManualImporter {
  final ManualRepository _repo;
  final String _rootDir;
  static const _uuid = Uuid();

  ManualImporter({required ManualRepository repo, required String rootDir})
      : _repo = repo,
        _rootDir = rootDir;

  /// 便捷工厂：用 [ManualRepository] + 应用文档目录构建。
  static Future<ManualImporter> create({required ManualRepository repo}) async {
    final docs = await getApplicationDocumentsDirectory();
    return ManualImporter(repo: repo, rootDir: docs.path);
  }

  /// 解析 JSON 字符串，返回将要导入的手册数（预览用，不落库）。
  static int countFromJson(String jsonStr) {
    final decoded = jsonDecode(jsonStr);
    if (decoded is! Map<String, dynamic>) return 0;
    final manuals = decoded['manuals'];
    if (manuals is! List) return 0;
    return manuals.length;
  }

  /// 导入全部手册。返回成功导入的数量。
  Future<int> importFromJson(String jsonStr) async {
    final decoded = jsonDecode(jsonStr);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('无效的手册 JSON：根对象不是 Map');
    }
    final manuals = decoded['manuals'];
    if (manuals is! List) {
      throw const FormatException('无效的手册 JSON：manuals 不是数组');
    }

    var imported = 0;
    for (final raw in manuals) {
      if (raw is! Map<String, dynamic>) continue;
      await _importOne(raw);
      imported++;
    }
    return imported;
  }

  Future<void> _importOne(Map<String, dynamic> raw) async {
    // id 映射：旧 manualId/stepId/imageId/tagId → 新 id，避免冲突。
    final oldToNewTagId = <String, String>{};
    final newTagIds = <String>[];
    final newManualId = _uuid.v4();
    final now = DateTime.now();

    // tags：先入库（用新 id），并建立 manual-tag 关联。
    final tagsRaw = raw['tags'];
    if (tagsRaw is List) {
      for (final t in tagsRaw) {
        if (t is! Map<String, dynamic>) continue;
        final oldId = t['id'] as String?;
        final newTagId = _uuid.v4();
        if (oldId != null) oldToNewTagId[oldId] = newTagId;
        await _repo.saveTag(domain.Tag(
          id: newTagId,
          name: (t['name'] as String?) ?? '标签',
          createdAt: _parseDate(t['createdAt']) ?? now,
        ));
      }
    }
    // 原 manual 的 tagIds 映射到新 tag id。
    final tagIdsRaw = raw['tagIds'];
    if (tagIdsRaw is List) {
      for (final oldId in tagIdsRaw) {
        if (oldId is String) {
          final mapped = oldToNewTagId[oldId] ?? oldId;
          newTagIds.add(mapped);
        }
      }
    }

    // 封面图。
    final coverPath = await _writeCover(
      manualId: newManualId,
      coverRaw: raw['coverImage'],
    );

    // steps。
    final steps = <domain.Step>[];
    final stepsRaw = raw['steps'];
    if (stepsRaw is List) {
      var stepIndex = 0;
      for (final sRaw in stepsRaw) {
        if (sRaw is! Map<String, dynamic>) continue;
        stepIndex++;
        final newStepId = _uuid.v4();
        final images = await _writeImages(
          manualId: newManualId,
          imagesRaw: sRaw['images'],
        );
        final optionalRaw = sRaw['optionalFields'];
        steps.add(domain.Step(
          id: newStepId,
          order: (sRaw['order'] as num?)?.toInt() ?? (stepIndex * 100),
          title: sRaw['title'] as String?,
          note: (sRaw['note'] as String?) ?? '',
          completed: (sRaw['completed'] as bool?) ?? false,
          createdAt: _parseDate(sRaw['createdAt']) ?? now,
          completedAt: _parseDate(sRaw['completedAt']),
          images: images,
          optionalFields: optionalRaw is Map
              ? Map<String, String>.from(
                  optionalRaw.map((k, v) => MapEntry('$k', '$v')))
              : const {},
        ));
      }
    }

    final manual = domain.Manual(
      id: newManualId,
      title: (raw['title'] as String?) ?? '导入的手册',
      coverImagePath: coverPath,
      isFavorite: (raw['isFavorite'] as bool?) ?? false,
      createdAt: _parseDate(raw['createdAt']) ?? now,
      updatedAt: now,
      sortKey: (raw['sortKey'] as num?)?.toInt() ?? 0,
      tagIds: newTagIds,
      tags: const [],
      steps: steps,
    );

    await _repo.saveManual(manual);
  }

  Future<String?> _writeCover({
    required String manualId,
    required dynamic coverRaw,
  }) async {
    if (coverRaw is! Map<String, dynamic>) return null;
    final b64 = coverRaw['base64'] as String?;
    if (b64 == null || b64.isEmpty) return null;
    final ext = (coverRaw['ext'] as String?) ?? '.jpg';
    final destDir = p.join(_rootDir, 'images', 'originals', manualId);
    return _writeBase64(
      b64: b64,
      ext: ext,
      destDir: destDir,
      name: _uuid.v4(),
    );
  }

  Future<List<domain.StepImage>> _writeImages({
    required String manualId,
    required dynamic imagesRaw,
  }) async {
    if (imagesRaw is! List) return const [];
    final out = <domain.StepImage>[];
    var imgIndex = 0;
    for (final iRaw in imagesRaw) {
      if (iRaw is! Map<String, dynamic>) continue;
      imgIndex++;
      final newImgId = _uuid.v4();
      final originalPath = await _writeBase64(
        b64: iRaw['original'] as String?,
        ext: (iRaw['originalExt'] as String?) ?? '.jpg',
        destDir: p.join(_rootDir, 'images', 'originals', manualId),
        name: _uuid.v4(),
      );
      final editedPath = await _writeBase64(
        b64: iRaw['edited'] as String?,
        ext: (iRaw['editedExt'] as String?) ?? '.jpg',
        destDir: p.join(_rootDir, 'images', 'edited', manualId),
        name: _uuid.v4(),
      );
      final thumbnailPath = await _writeBase64(
        b64: iRaw['thumbnail'] as String?,
        ext: (iRaw['thumbnailExt'] as String?) ?? '.jpg',
        destDir: p.join(_rootDir, 'thumbnails', manualId),
        name: newImgId,
      );
      // 缩略图缺失时回退到原图路径，避免空指针。
      out.add(domain.StepImage(
        id: newImgId,
        order: (iRaw['order'] as num?)?.toInt() ?? (imgIndex * 100),
        originalPath: originalPath ?? '',
        editedPath: editedPath,
        thumbnailPath: thumbnailPath ?? originalPath ?? '',
      ));
    }
    return out;
  }

  Future<String?> _writeBase64({
    required String? b64,
    required String ext,
    required String destDir,
    required String name,
  }) async {
    if (b64 == null || b64.isEmpty) return null;
    final dir = Directory(destDir);
    await dir.create(recursive: true);
    final dest = p.join(destDir, '$name$ext');
    await File(dest).writeAsBytes(base64Decode(b64));
    return dest;
  }

  DateTime? _parseDate(dynamic v) {
    if (v is! String || v.isEmpty) return null;
    return DateTime.tryParse(v);
  }
}
