import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers.dart';
import '../data/manual_importer.dart';

/// 导入手册对话框：选 .json 文件 → 预览数量 → 确认导入。
class ImportDialog extends ConsumerStatefulWidget {
  const ImportDialog({super.key});

  @override
  ConsumerState<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<ImportDialog> {
  String? _jsonContent;
  int _previewCount = 0;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('导入手册'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('从其他设备导出的 JSON 文件导入手册。导入会生成新的 ID，不会覆盖现有数据。'),
            const SizedBox(height: 12),
            if (_jsonContent == null)
              const Text('未选择文件', style: TextStyle(color: Colors.grey))
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('将导入 $_previewCount 本手册'),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _busy ? null : _pickFile,
              icon: const Icon(Icons.file_open),
              label: Text(_jsonContent == null ? '选择 JSON 文件' : '重新选择'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: (_busy || _jsonContent == null) ? null : _doImport,
          child: _busy
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('导入'),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    String? content;
    if (f.bytes != null) {
      content = utf8.decode(f.bytes!, allowMalformed: true);
    } else if (f.path != null) {
      content = await File(f.path!).readAsString();
    }
    if (content == null) return;
    final c = content;
    setState(() {
      _jsonContent = c;
      _previewCount = ManualImporter.countFromJson(c);
    });
  }

  Future<void> _doImport() async {
    if (_jsonContent == null) return;
    setState(() => _busy = true);
    try {
      final repo = await ref.read(manualRepositoryProvider.future);
      final importer = await ManualImporter.create(repo: repo);
      final count = await importer.importFromJson(_jsonContent!);
      if (mounted) {
        ref.invalidate(manualRepositoryProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功导入 $count 本手册')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导入失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
