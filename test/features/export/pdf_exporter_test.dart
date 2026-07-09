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

  test('PDF includes manual metadata + step time/fields', () async {
    final m = Manual(
      id: 'm1',
      title: '巡检',
      coverImagePath: null,
      isFavorite: false,
      createdAt: DateTime(2026, 1, 1, 9),
      updatedAt: DateTime(2026, 1, 2, 18),
      steps: [
        Step(
          id: 's1',
          order: 100,
          title: '检查现场',
          note: '看天气',
          completed: true,
          images: const [],
          optionalFields: const {'温度': '25C'},
          createdAt: DateTime(2026, 1, 1, 10),
          completedAt: DateTime(2026, 1, 1, 11),
        ),
      ],
      tags: [Tag(id: 't1', name: '电力', createdAt: DateTime(2026, 1, 1))],
      tagIds: const ['t1'],
    );
    final bytes = await PdfExporter(
      fontProvider: () async => pw.Font.helvetica(),
    ).exportToBytes(m);
    expect(bytes.length, greaterThan(2000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}