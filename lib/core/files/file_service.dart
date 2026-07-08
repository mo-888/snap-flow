import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class FileService {
  final String root;
  final _uuid = const Uuid();

  FileService({required this.root});

  String get _originalsDir => p.join(root, 'images', 'originals');
  String get _editedDir => p.join(root, 'images', 'edited');
  String get _thumbnailsDir => p.join(root, 'thumbnails');

  Future<void> init() async {
    for (final d in [_originalsDir, _editedDir, _thumbnailsDir]) {
      await Directory(d).create(recursive: true);
    }
  }

  Future<String> copyOriginal(String manualId, File src) async {
    final dir = Directory(p.join(_originalsDir, manualId));
    await dir.create(recursive: true);
    final ext = p.extension(src.path);
    final name = '${_uuid.v4()}$ext';
    final dest = p.join(dir.path, name);
    await src.copy(dest);
    return dest;
  }

  Future<String> copyEdited(String manualId, File src) async {
    final dir = Directory(p.join(_editedDir, manualId));
    await dir.create(recursive: true);
    final ext = p.extension(src.path);
    final name = '${_uuid.v4()}$ext';
    final dest = p.join(dir.path, name);
    await src.copy(dest);
    return dest;
  }

  Future<String> saveThumbnail(String manualId, String imageId, List<int> bytes) async {
    final dir = Directory(p.join(_thumbnailsDir, manualId));
    await dir.create(recursive: true);
    final dest = p.join(dir.path, '$imageId.jpg');
    await File(dest).writeAsBytes(bytes);
    return dest;
  }

  Future<void> deleteManualImages(String manualId) async {
    for (final base in [_originalsDir, _editedDir, _thumbnailsDir]) {
      final dir = Directory(p.join(base, manualId));
      if (dir.existsSync()) await dir.delete(recursive: true);
    }
  }
}