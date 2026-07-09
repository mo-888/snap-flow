import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/features/import_export/data/manual_exporter.dart';
import 'package:snapflow/features/import_export/data/manual_importer.dart';
import 'package:snapflow/features/manual/domain/entities.dart';
import 'package:snapflow/features/manual/domain/manual_repository.dart';

/// 用于追踪 tag 保存与 manual 写入的内存仓库。
class _TrackRepo implements ManualRepository {
  final List<Manual> manuals = [];
  final List<Tag> tags = [];

  @override
  Future<List<Manual>> listManuals() async => List.unmodifiable(manuals);

  @override
  Future<Manual?> getManual(String id) async =>
      manuals.where((m) => m.id == id).cast<Manual?>().firstOrNull;

  @override
  Future<void> saveManual(Manual manual) async {
    manuals.removeWhere((m) => m.id == manual.id);
    manuals.add(manual);
  }

  @override
  Future<void> deleteManual(String id) async {
    manuals.removeWhere((m) => m.id == id);
  }

  @override
  Future<List<Tag>> listTags() async => List.unmodifiable(tags);

  @override
  Future<void> saveTag(Tag tag) async {
    tags.removeWhere((t) => t.id == tag.id);
    tags.add(tag);
  }

  @override
  Future<void> deleteTag(String id) async {
    tags.removeWhere((t) => t.id == id);
  }
}

Manual _sampleManual() {
  final now = DateTime(2026, 7, 9, 10, 0);
  return Manual(
    id: 'm-orig',
    title: '示例手册',
    coverImagePath: null,
    isFavorite: true,
    createdAt: now,
    updatedAt: now,
    sortKey: 3,
    tagIds: const ['t1'],
    tags: [Tag(id: 't1', name: '工作', createdAt: now)],
    steps: [
      Step(
        id: 's1',
        order: 100,
        title: '步骤一',
        note: '注意安全',
        completed: false,
        createdAt: now,
        completedAt: null,
        images: const [],
        optionalFields: const {'时长': '5分钟'},
      ),
      Step(
        id: 's2',
        order: 200,
        title: '步骤二',
        note: '',
        completed: true,
        createdAt: now,
        completedAt: now,
        images: const [],
        optionalFields: const {},
      ),
    ],
  );
}

void main() {
  group('ManualExporter', () {
    test('toJson 生成合法 JSON 信封', () async {
      final json = await ManualExporter().toJson([_sampleManual()]);
      expect(json, contains('"version": 1'));
      expect(json, contains('"manuals"'));
      expect(json, contains('示例手册'));
      expect(json, contains('步骤一'));
      expect(json, contains('工作'));
    });

    test('countFromJson 正确计数', () {
      final json = '{"version":1,"manuals":[{},{},{}]}';
      expect(ManualImporter.countFromJson(json), 3);
    });

    test('countFromJson 非法输入返回 0', () {
      expect(ManualImporter.countFromJson('[]'), 0);
      expect(ManualImporter.countFromJson('"x"'), 0);
      expect(ManualImporter.countFromJson('{}'), 0);
    });
  });

  group('ManualImporter round-trip', () {
    test('导出再导入：手册/步骤/标签结构保留', () async {
      final orig = _sampleManual();
      final json = await ManualExporter().toJson([orig]);

      final repo = _TrackRepo();
      final tmpRoot = '/tmp/snapflow_test_struct';
      final importer = ManualImporter(repo: repo, rootDir: tmpRoot);

      final count = await importer.importFromJson(json);
      expect(count, 1);

      final imported = repo.manuals.single;
      expect(imported.title, '示例手册');
      expect(imported.isFavorite, isTrue);
      expect(imported.sortKey, 3);
      expect(imported.steps.length, 2);
      expect(imported.steps[0].title, '步骤一');
      expect(imported.steps[0].note, '注意安全');
      expect(imported.steps[0].optionalFields['时长'], '5分钟');
      expect(imported.steps[1].completed, isTrue);
      expect(imported.steps[1].completedAt, isNotNull);
      expect(repo.tags, isNotEmpty);
      expect(repo.tags.first.name, '工作');
      expect(imported.tagIds, isNotEmpty);
    });

    test('导入为手册生成新 id（不与原 id 冲突）', () async {
      final orig = _sampleManual();
      final json = await ManualExporter().toJson([orig]);

      final repo = _TrackRepo();
      final importer = ManualImporter(repo: repo, rootDir: '/tmp/snapflow_test_noid');
      await importer.importFromJson(json);

      expect(repo.manuals.single.id, isNot('m-orig'));
      expect(repo.manuals.single.steps.first.id, isNot('s1'));
    });

    test('空 manuals 数组导入 0 本', () async {
      final json = '{"version":1,"manuals":[]}';
      final repo = _TrackRepo();
      final importer = ManualImporter(repo: repo, rootDir: '/tmp/snapflow_test_empty');
      final count = await importer.importFromJson(json);
      expect(count, 0);
      expect(repo.manuals, isEmpty);
    });

    test('非法 JSON 抛 FormatException', () async {
      final repo = _TrackRepo();
      final importer = ManualImporter(repo: repo, rootDir: '/tmp/snapflow_test_bad');
      expect(() => importer.importFromJson('[]'),
          throwsA(isA<FormatException>()));
    });
  });
}
