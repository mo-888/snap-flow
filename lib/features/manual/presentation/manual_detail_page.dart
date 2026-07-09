import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../export/pdf_exporter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/snap_toast.dart';
import '../../../shared/providers.dart';
import '../domain/entities.dart' as domain;
import 'home_page.dart';
import 'step_edit_page.dart';
import 'widgets/step_tile.dart';

final manualDetailProvider = FutureProvider.family<domain.Manual?, String>((ref, id) async {
  final repo = await ref.watch(manualRepositoryProvider.future);
  return repo.getManual(id);
});

class ManualDetailPage extends ConsumerStatefulWidget {
  final String manualId;
  /// 进入后自动打开该 step 编辑页（来自"快速拍照"流程）。
  final String? autoCaptureStepId;
  const ManualDetailPage({super.key, required this.manualId, this.autoCaptureStepId});

  @override
  ConsumerState<ManualDetailPage> createState() => _ManualDetailPageState();
}

class _ManualDetailPageState extends ConsumerState<ManualDetailPage> {
  @override
  void initState() {
    super.initState();
    if (widget.autoCaptureStepId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => StepEditPage(manualId: widget.manualId, stepId: widget.autoCaptureStepId!),
        ));
      });
    }
  }

  String get _manualId => widget.manualId;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(manualDetailProvider(_manualId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: async.maybeWhen(
          data: (m) => Text(m?.title.isNotEmpty == true ? m!.title : '未命名'),
          orElse: () => const Text('手册'),
        ),
        actions: [
          async.maybeWhen(
            data: (m) => IconButton(
              icon: Icon(m?.isFavorite == true ? Icons.star : Icons.star_border,
                  color: m?.isFavorite == true ? Theme.of(context).colorScheme.tertiary : null),
              onPressed: () => _toggleFav(m),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: '导出 PDF',
            onPressed: () => _exportPdf(_manualId),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (manual) {
          if (manual == null) {
            return const EmptyState(icon: Icons.error_outline, title: '手册不存在');
          }
          if (manual.steps.isEmpty) {
            return const EmptyState(icon: Icons.add_box_outlined, title: '还没有步骤', hint: '点击下方"加步骤"开始记录');
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: manual.steps.length,
            // ignore: deprecated_member_use
            onReorder: (oldIdx, newIdx) => _onReorder(manual, oldIdx, newIdx),
            itemBuilder: (_, i) => StepTile(
              key: ValueKey(manual.steps[i].id),
              index: i,
              step: manual.steps[i],
              onEdit: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => StepEditPage(manualId: manual.id, stepId: manual.steps[i].id),
              )),
              onDelete: () => _onDelete(manual, manual.steps[i].id),
              onDuplicate: () => _onDuplicate(manual, manual.steps[i]),
              onToggleComplete: () => _onToggleComplete(manual, manual.steps[i]),
            ),
          );
        },
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _onAddStep(_manualId),
                    icon: const Icon(Icons.add),
                    label: const Text('加步骤'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _exportPdf(_manualId),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('导出 PDF'),
                  ),
                ),
              ],
            ),
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Future<void> _toggleFav(domain.Manual? m) async {
    if (m == null) return;
    final repo = await ref.read(manualRepositoryProvider.future);
    await repo.saveManual(m.copyWith(isFavorite: !m.isFavorite));
    ref.invalidate(manualDetailProvider(m.id));
    ref.invalidate(manualListProvider);
  }

  Future<void> _onAddStep(String manualId) async {
    final repo = await ref.read(manualRepositoryProvider.future);
    final m = await repo.getManual(manualId);
    if (m == null) return;
    if (!mounted) return;
    final now = DateTime.now();
    final newStep = domain.Step(
      id: 's-${now.millisecondsSinceEpoch}',
      order: (m.steps.isEmpty ? 100 : m.steps.last.order + 100),
      title: null, note: '', completed: false, images: const [], optionalFields: const {},
    );
    await repo.saveManual(m.copyWith(steps: [...m.steps, newStep], updatedAt: now));
    ref.invalidate(manualDetailProvider(manualId));
    ref.invalidate(manualListProvider);
    if (mounted) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => StepEditPage(manualId: manualId, stepId: newStep.id),
      ));
    }
  }

  Future<void> _onReorder(domain.Manual m, int oldIdx, int newIdx) async {
    final list = [...m.steps];
    final item = list.removeAt(oldIdx);
    final insertIdx = newIdx > oldIdx ? newIdx - 1 : newIdx;
    list.insert(insertIdx, item);
    final reordered = [for (var i = 0; i < list.length; i++) list[i].copyWith(order: (i + 1) * 100)];
    final repo = await ref.read(manualRepositoryProvider.future);
    await repo.saveManual(m.copyWith(steps: reordered, updatedAt: DateTime.now()));
    ref.invalidate(manualDetailProvider(m.id));
    ref.invalidate(manualListProvider);
  }

  Future<void> _onDelete(domain.Manual m, String stepId) async {
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
    await repo.saveManual(m.copyWith(
      steps: m.steps.where((s) => s.id != stepId).toList(),
      updatedAt: DateTime.now(),
    ));
    ref.invalidate(manualDetailProvider(m.id));
    ref.invalidate(manualListProvider);
    if (mounted) SnapToast.show(context, '已删除', success: true);
  }

  Future<void> _onDuplicate(domain.Manual m, domain.Step s) async {
    final now = DateTime.now();
    final dup = s.copyWith(
      id: 's-${now.millisecondsSinceEpoch}-dup',
      order: s.order + 50,
      images: const [],
    );
    final repo = await ref.read(manualRepositoryProvider.future);
    final newSteps = [...m.steps, dup]..sort((a, b) => a.order.compareTo(b.order));
    await repo.saveManual(m.copyWith(steps: newSteps, updatedAt: now));
    ref.invalidate(manualDetailProvider(m.id));
    ref.invalidate(manualListProvider);
  }

  Future<void> _onToggleComplete(domain.Manual m, domain.Step s) async {
    final repo = await ref.read(manualRepositoryProvider.future);
    final newSteps = m.steps.map((x) => x.id == s.id ? x.copyWith(completed: !x.completed) : x).toList();
    await repo.saveManual(m.copyWith(steps: newSteps, updatedAt: DateTime.now()));
    ref.invalidate(manualDetailProvider(m.id));
    ref.invalidate(manualListProvider);
    if (mounted) {
      SnapToast.show(context, !s.completed ? '已完成' : '已撤销', success: true);
    }
  }

  Future<void> _exportPdf(String manualId) async {
    final repo = await ref.read(manualRepositoryProvider.future);
    final m = await repo.getManual(manualId);
    if (m == null || !mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('生成 PDF…')]),
      ),
    );
    try {
      final bytes = await PdfExporter().exportToBytes(m);
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        SnapToast.show(context, 'PDF 已生成（${bytes.length ~/ 1024} KB）', success: true);
      }
      await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: '${m.title}.pdf');
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) SnapToast.show(context, '导出失败：$e', error: true);
    }
  }
}