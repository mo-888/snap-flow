import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/features/template/template_service.dart';

void main() {
  test('loads built-in templates from assets', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final svc = TemplateService();
    final list = await svc.listTemplates();
    expect(list.length, 2);
    expect(list.first.name, '电力巡检');
  });
}