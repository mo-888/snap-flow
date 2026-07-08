import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../shared/providers.dart';
import '../../../features/export/pdf_exporter.dart';
import '../domain/entities.dart' as domain;
import 'home_page.dart';
import 'step_edit_page.dart';
import 'widgets/step_tile.dart';

final manualDetailProvider = FutureProvider.family<domain.Manual?, String>((ref, id) async {
  final repo = await ref.watch(manualRepositoryProvider.future);
  return repo.getManual(id);
});

class ManualDetailPage extends ConsumerWidget {
  final String manualId;
  const ManualDetailPage({super.key, required this.manualId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(manualDetailProvider(manualId));
    return Scaffold(
      appBar: AppBar(
        title: async.maybeWhen(
          data: (m) => Text(m?.title.isNotEmpty == true ? m!.title : '未命名'),
          orElse: () => const Text('手册'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportPdf(context, ref, manualId),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (manual) {
          if (manual == null) return const Center(child: Text('手册不存在'));
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: manual.steps.length,
            // ignore: deprecated_member_use
            onReorder: (oldIdx, newIdx) => _onReorder(ref, manual, oldIdx, newIdx),
            itemBuilder: (_, i) {
              final s = manual.steps[i];
              return StepTile(
                key: ValueKey(s.id),
                step: s,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StepEditPage(manualId: manual.id, stepId: s.id),
                  ),
                ),
                onDelete: () => _onDelete(context, ref, manual, s.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onAddStep(context, ref, manualId),
        icon: const Icon(Icons.add),
        label: const Text('添加步骤'),
      ),
    );
  }

  Future<void> _onAddStep(BuildContext context, WidgetRef ref, String manualId) async {
    final repo = await ref.read(manualRepositoryProvider.future);
    final m = await repo.getManual(manualId);
    if (m == null) return;
    final now = DateTime.now();
    final newStep = domain.Step(
      id: 's-${now.millisecondsSinceEpoch}',
      order: (m.steps.isEmpty ? 100 : m.steps.last.order + 100),
      title: null,
      note: '',
      completed: false,
      images: const [],
      optionalFields: const {},
    );
    await repo.saveManual(m.copyWith(
      steps: [...m.steps, newStep],
      updatedAt: now,
    ));
    ref.invalidate(manualDetailProvider(manualId));
    ref.invalidate(manualListProvider);
  }

  Future<void> _onReorder(WidgetRef ref, domain.Manual m, int oldIdx, int newIdx) async {
    final list = [...m.steps];
    final item = list.removeAt(oldIdx);
    final insertIdx = newIdx > oldIdx ? newIdx - 1 : newIdx;
    list.insert(insertIdx, item);
    final reordered = <domain.Step>[];
    for (var i = 0; i < list.length; i++) {
      reordered.add(list[i].copyWith(order: (i + 1) * 100));
    }
    final repo = await ref.read(manualRepositoryProvider.future);
    await repo.saveManual(m.copyWith(steps: reordered, updatedAt: DateTime.now()));
    ref.invalidate(manualDetailProvider(m.id));
    ref.invalidate(manualListProvider);
  }

  Future<void> _onDelete(BuildContext context, WidgetRef ref, domain.Manual m, String stepId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除步骤？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;
    final repo = await ref.read(manualRepositoryProvider.future);
    final newSteps = m.steps.where((s) => s.id != stepId).toList();
    await repo.saveManual(m.copyWith(steps: newSteps, updatedAt: DateTime.now()));
    ref.invalidate(manualDetailProvider(m.id));
    ref.invalidate(manualListProvider);
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref, String manualId) async {
    final repo = await ref.read(manualRepositoryProvider.future);
    final m = await repo.getManual(manualId);
    if (m == null) return;
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('生成 PDF…')]),
      ),
    );
    try {
      final bytes = await PdfExporter().exportToBytes(m);
      if (context.mounted) Navigator.of(context).pop();
      await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: '${m.title}.pdf');
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败：$e')));
      }
    }
  }
}