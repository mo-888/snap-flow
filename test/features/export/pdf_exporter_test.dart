import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:snapflow/features/export/pdf_exporter.dart';
import 'package:snapflow/features/manual/domain/entities.dart';

void main() {
  test('exports PDF bytes for a manual', () async {
    final m = Manual(
      id: 'm1',
      title: 'Test Manual',
      coverImagePath: null,
      isFavorite: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      steps: [
        Step(
          id: 's1',
          order: 100,
          title: 'Step 1',
          note: 'Do this',
          completed: false,
          images: const [],
          optionalFields: const {},
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    );
    // 注入 helvetica 字体，避免单测中加载 asset bundle。
    final out = await PdfExporter(
      fontProvider: () async => pw.Font.helvetica(),
    ).exportToBytes(m);
    expect(out.length, greaterThan(100));
    expect(String.fromCharCodes(out.take(4)), equals('%PDF'));
  });
}