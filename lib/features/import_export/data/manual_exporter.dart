import 'dart:convert';
import 'dart:io';
import '../../manual/domain/entities.dart';

/// 手册导出为 JSON。图片以 base64 内嵌，便于单文件传输。
class ManualExporter {
  /// 导出给定手册列表。`coverImagePath` 与 step 图片均会以 base64 内嵌。
  Future<String> toJson(List<Manual> manuals) async {
    final out = <Map<String, dynamic>>[];
    for (final m in manuals) {
      out.add(await _manualToJson(m));
    }
    final envelope = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'manuals': out,
    };
    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  Future<Map<String, dynamic>> _manualToJson(Manual m) async {
    final stepsJson = <Map<String, dynamic>>[];
    for (final s in m.steps) {
      stepsJson.add({
        'id': s.id,
        'order': s.order,
        'title': s.title,
        'note': s.note,
        'completed': s.completed,
        'createdAt': s.createdAt.toIso8601String(),
        'completedAt': s.completedAt?.toIso8601String(),
        'optionalFields': s.optionalFields,
        'images': await _imagesToJson(s.images),
      });
    }

    return {
      'id': m.id,
      'title': m.title,
      'isFavorite': m.isFavorite,
      'createdAt': m.createdAt.toIso8601String(),
      'updatedAt': m.updatedAt.toIso8601String(),
      'sortKey': m.sortKey,
      'tagIds': m.tagIds,
      'tags': m.tags
          .map((t) => {
                'id': t.id,
                'name': t.name,
                'createdAt': t.createdAt.toIso8601String(),
              })
          .toList(),
      'coverImage': await _maybeImageBase64(m.coverImagePath),
      'steps': stepsJson,
    };
  }

  Future<List<Map<String, dynamic>>> _imagesToJson(List<StepImage> images) async {
    final out = <Map<String, dynamic>>[];
    for (final img in images) {
      out.add({
        'id': img.id,
        'order': img.order,
        'original': await _fileBase64(img.originalPath),
        'edited': await _fileBase64(img.editedPath),
        'thumbnail': await _fileBase64(img.thumbnailPath),
        'originalExt': _ext(img.originalPath),
        'editedExt': _ext(img.editedPath),
        'thumbnailExt': _ext(img.thumbnailPath),
      });
    }
    return out;
  }

  /// 封面图单独处理：存 path + base64（若有）。
  Future<Map<String, dynamic>?> _maybeImageBase64(String? path) async {
    if (path == null || path.isEmpty) return null;
    final b64 = await _fileBase64(path);
    if (b64 == null) return null;
    return {'base64': b64, 'ext': _ext(path)};
  }

  Future<String?> _fileBase64(String? path) async {
    if (path == null || path.isEmpty) return null;
    final f = File(path);
    if (!await f.exists()) return null;
    final bytes = await f.readAsBytes();
    return base64Encode(bytes);
  }

  String _ext(String? path) {
    if (path == null || path.isEmpty) return '.jpg';
    final dot = path.lastIndexOf('.');
    if (dot < 0) return '.jpg';
    return path.substring(dot);
  }
}
