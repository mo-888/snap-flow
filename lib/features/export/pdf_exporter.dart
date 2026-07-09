import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../manual/domain/entities.dart';

/// 加载并缓存思源黑体（NotoSansSC），用于 PDF 中文渲染。
pw.Font? _cachedFont;

Future<pw.Font> _loadChineseFont() async {
  if (_cachedFont != null) return _cachedFont!;
  final bytes = await rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf');
  _cachedFont = pw.Font.ttf(bytes);
  return _cachedFont!;
}

typedef FontProvider = Future<pw.Font> Function();

class PdfExporter {
  /// 字体加载器；测试可注入空实现以跳过 asset bundle。
  final FontProvider? fontProvider;

  PdfExporter({this.fontProvider});

  Future<List<int>> exportToBytes(Manual manual) async {
    final chineseFont = await (fontProvider ?? _loadChineseFont)();
    final theme = pw.ThemeData.withFont(base: chineseFont);

    final doc = pw.Document(theme: theme);

    final stepWidgets = <pw.Widget>[];
    for (final s in manual.steps) {
      final imageWidgets = <pw.Widget>[];
      for (final img in s.images) {
        final path = img.editedPath ?? img.originalPath;
        if (File(path).existsSync()) {
          imageWidgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Image(pw.MemoryImage(File(path).readAsBytesSync()), height: 200),
            ),
          );
        }
      }
      stepWidgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300, width: 1)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('步骤 ${(s.order / 100).round()}: ${s.title ?? '(无标题)'}',
                  style: pw.TextStyle(font: chineseFont, fontSize: 14, fontWeight: pw.FontWeight.bold)),
              if (s.note.isNotEmpty) pw.SizedBox(height: 4),
              if (s.note.isNotEmpty)
                pw.Text(s.note, style: pw.TextStyle(font: chineseFont, fontSize: 11)),
              ...imageWidgets,
            ],
          ),
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text(manual.title.isEmpty ? '未命名手册' : manual.title,
                style: pw.TextStyle(font: chineseFont, fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 12),
          ...stepWidgets,
        ],
      ),
    );

    return doc.save();
  }
}
