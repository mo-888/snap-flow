import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/db/database.dart';
import '../core/files/file_service.dart';
import '../features/manual/data/manual_repository_impl.dart';
import '../features/manual/domain/manual_repository.dart';

const _uuid = Uuid();

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final fileServiceProvider = FutureProvider<FileService>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final fs = FileService(root: dir.path);
  await fs.init();
  return fs;
});

final manualRepositoryProvider = FutureProvider<ManualRepository>((ref) async {
  final db = ref.watch(databaseProvider);
  final fs = await ref.watch(fileServiceProvider.future);
  return ManualRepositoryImpl(db: db, files: fs);
});

Future<String> savePickedImage({
  required File source,
  required String manualId,
}) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, 'images', 'originals', manualId));
  await dir.create(recursive: true);
  final ext = p.extension(source.path).isEmpty ? '.jpg' : p.extension(source.path);
  final id = _uuid.v4();
  final dest = File(p.join(dir.path, '$id$ext'));
  await source.copy(dest.path);
  return dest.path;
}

Future<String> generateThumbnailFor({
  required File source,
  required String manualId,
  required String imageId,
}) async {
  final bytes = await source.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw Exception('Cannot decode image: ${source.path}');
  }
  final thumb = img.copyResize(decoded, width: 256);
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, 'thumbnails', manualId));
  await dir.create(recursive: true);
  final out = File(p.join(dir.path, '$imageId.jpg'));
  await out.writeAsBytes(img.encodeJpg(thumb, quality: 80));
  return out.path;
}