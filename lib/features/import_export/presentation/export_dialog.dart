import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers.dart';
import '../../manual/domain/entities.dart' as domain;
import '../../manual/presentation/home_page.dart' show manualListProvider;
import '../data/manual_exporter.dart';

enum _ExportScope { all, favorite, withTag }

/// 手册导出对话框：全选 / 按收藏 / 按标签筛选，输出 JSON 字符串。
/// 调用方拿到 [ExportResult.json] 后自行决定保存/分享。
class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({super.key});

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  _ExportScope _scope = _ExportScope.all;
  String? _selectedTagId;
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsProvider);
    return AlertDialog(
      title: const Text('导出手册'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RadioGroup<_ExportScope>(
              groupValue: _scope,
              onChanged: (v) {
                if (v != null) setState(() => _scope = v);
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<_ExportScope>(
                    value: _ExportScope.all,
                    title: Text('全部手册'),
                  ),
                  RadioListTile<_ExportScope>(
                    value: _ExportScope.favorite,
                    title: Text('仅收藏'),
                  ),
                  RadioListTile<_ExportScope>(
                    value: _ExportScope.withTag,
                    title: Text('按标签'),
                  ),
                ],
              ),
            ),
            if (_scope == _ExportScope.withTag)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: tagsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(8),
                    child: LinearProgressIndicator(),
                  ),
                  error: (e, _) => Text('标签加载失败：$e'),
                  data: (tags) => DropdownButton<String?>(
                    isExpanded: true,
                    value: _selectedTagId ?? (tags.isEmpty ? null : tags.first.id),
                    hint: const Text('选择标签'),
                    items: [
                      for (final t in tags)
                        DropdownMenuItem<String?>(value: t.id, child: Text(t.name)),
                    ],
                    onChanged: (v) => setState(() => _selectedTagId = v),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              _hint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _exporting ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _exporting ? null : _doExport,
          child: _exporting
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('导出'),
        ),
      ],
    );
  }

  String get _hint {
    switch (_scope) {
      case _ExportScope.all:
        return '将导出所有手册及其步骤、图片（base64 内嵌）。';
      case _ExportScope.favorite:
        return '仅导出已收藏的手册。';
      case _ExportScope.withTag:
        return '导出包含所选标签的手册。';
    }
  }

  Future<void> _doExport() async {
    setState(() => _exporting = true);
    try {
      final manuals = await ref.read(manualListProvider.future);
      final filtered = _filter(manuals);
      if (filtered.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('没有符合条件的手册')),
          );
          Navigator.of(context).pop();
        }
        return;
      }
      final json = await ManualExporter().toJson(filtered);
      if (mounted) Navigator.of(context).pop(ExportResult(json: json, count: filtered.length));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  List<domain.Manual> _filter(List<domain.Manual> manuals) {
    switch (_scope) {
      case _ExportScope.all:
        return manuals;
      case _ExportScope.favorite:
        return manuals.where((m) => m.isFavorite).toList();
      case _ExportScope.withTag:
        final tid = _selectedTagId;
        if (tid == null) return manuals;
        return manuals.where((m) => m.tagIds.contains(tid)).toList();
    }
  }
}

class ExportResult {
  final String json;
  final int count;
  const ExportResult({required this.json, required this.count});
}
