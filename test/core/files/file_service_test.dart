import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:snapflow/core/files/file_service.dart';

void main() {
  late Directory tempRoot;
  late FileService fs;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('snapflow_test_');
    fs = FileService(root: tempRoot.path);
    await fs.init();
  });

  tearDown(() async {
    if (tempRoot.existsSync()) await tempRoot.delete(recursive: true);
  });

  test('init creates three directories', () {
    expect(Directory(p.join(tempRoot.path, 'images/originals')).existsSync(), isTrue);
    expect(Directory(p.join(tempRoot.path, 'images/edited')).existsSync(), isTrue);
    expect(Directory(p.join(tempRoot.path, 'thumbnails')).existsSync(), isTrue);
  });

  test('copyOriginal / saveThumbnail return usable paths', () async {
    final src = File(p.join(tempRoot.path, 'src.jpg'))..writeAsBytesSync([1, 2, 3]);
    final orig = await fs.copyOriginal('m1', src);
    final thumb = await fs.saveThumbnail('m1', 'img1', [9, 9, 9]);
    expect(File(orig).existsSync(), isTrue);
    expect(File(thumb).existsSync(), isTrue);
  });

  test('deleteManualImages clears only that manual', () async {
    final src = File(p.join(tempRoot.path, 'src.jpg'))..writeAsBytesSync([1]);
    await fs.copyOriginal('m1', src);
    await fs.saveThumbnail('m1', 'i1', [1]);
    await fs.deleteManualImages('m1');
    expect(Directory(p.join(tempRoot.path, 'images/originals/m1')).existsSync(), isFalse);
  });
}
