import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/core/db/database.dart';
import 'package:drift/native.dart';
import 'package:snapflow/features/template/template_service.dart';

void main() {
  test('loads built-in templates from assets', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final db = AppDatabase(NativeDatabase.memory());
    final svc = TemplateService(db: db);
    final list = await svc.listBuiltin();
    expect(list.length, 2);
    expect(list.first.name, '电力巡检');
    expect(list.first.isBuiltin, true);
    await db.close();
  });
}