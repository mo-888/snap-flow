import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../manual/domain/entities.dart';

class PdfExporter {
  Future<List<int>> exportToBytes(Manual manual) async {
    final doc = pw.Document();

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
                  style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              if (s.note.isNotEmpty) pw.SizedBox(height: 4),
              if (s.note.isNotEmpty) pw.Text(s.note, style: const pw.TextStyle(fontSize: 11)),
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
                style: const pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 12),
          ...stepWidgets,
        ],
      ),
    );

    return doc.save();
  }
}