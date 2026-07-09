import 'dart:io';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/snap_toast.dart';
import '../../import_export/presentation/export_dialog.dart';
import '../../import_export/presentation/import_dialog.dart';
import '../../tag/presentation/tag_manager_page.dart';
import '../../tag/presentation/widgets/tag_filter_sheet.dart';
import '../../template/presentation/template_manager_page.dart';
import '../../template/template_sheet.dart';
import '../domain/entities.dart';
import 'manual_detail_page.dart';
import 'widgets/manual_card.dart';

enum ManualFilter { all, recent, favorites, incomplete }

final manualFilterProvider = StateProvider<ManualFilter>((_) => ManualFilter.all);
final manualSearchProvider = StateProvider<String>((_) => '');

final manualListProvider = FutureProvider<List<Manual>>((ref) async {
  final repo = await ref.watch(manualRepositoryProvider.future);
  return repo.listManuals();
});

final filteredManualsProvider = Provider<AsyncValue<List<Manual>>>((ref) {
  final async = ref.watch(manualListProvider);
  final filter = ref.watch(manualFilterProvider);
  final q = ref.watch(manualSearchProvider).toLowerCase();
  final selectedTagIds = ref.watch(selectedTagIdsProvider);
  final sort = ref.watch(manualSortProvider);
  return async.whenData((list) {
    final filtered = list.where((m) {
      if (q.isNotEmpty && !m.title.toLowerCase().contains(q)) return false;
      switch (filter) {
        case ManualFilter.all: break;
        case ManualFilter.favorites:
          if (!m.isFavorite) return false;
          break;
        case ManualFilter.incomplete:
          if (!(m.steps.isNotEmpty && m.steps.any((s) => !s.completed))) return false;
          break;
        case ManualFilter.recent:
          if (!m.updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))) return false;
          break;
      }
      if (selectedTagIds.isNotEmpty) {
        final hasAny = m.tagIds.any(selectedTagIds.contains);
        if (!hasAny) return false;
      }
      return true;
    }).toList();

    int cmp(Manual a, Manual b) {
      switch (sort) {
        case ManualSort.updatedDesc:
          return b.updatedAt.compareTo(a.updatedAt);
        case ManualSort.createdDesc:
          return b.createdAt.compareTo(a.createdAt);
        case ManualSort.titleAsc:
          return a.title.compareTo(b.title);
        case ManualSort.completionDesc:
          final aDone = a.steps.where((s) => s.completed).length / (a.steps.isEmpty ? 1 : a.steps.length);
          final bDone = b.steps.where((s) => s.completed).length / (b.steps.isEmpty ? 1 : b.steps.length);
          return bDone.compareTo(aDone);
      }
    }

    filtered.sort(cmp);
    return filtered;
  });
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredManualsProvider);
    final filter = ref.watch(manualFilterProvider);
    final selectedTagIds = ref.watch(selectedTagIdsProvider);
    final sort = ref.watch(manualSortProvider);

    Future<void> toggleFav(Manual m) async {
      final repo = await ref.read(manualRepositoryProvider.future);
      await repo.saveManual(m.copyWith(isFavorite: !m.isFavorite));
      ref.invalidate(manualListProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的手册'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.import_export),
            tooltip: '导入/导出',
            onSelected: (v) {
              if (v == 'import') {
                showDialog(context: context, builder: (_) => const ImportDialog());
              } else if (v == 'export') {
                _showExport(context, ref);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'import', child: ListTile(leading: Icon(Icons.file_download), title: Text('导入手册'))),
              PopupMenuItem(value: 'export', child: ListTile(leading: Icon(Icons.file_upload), title: Text('导出手册'))),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: '排序',
            onPressed: () async {
              final next = await showModalBottomSheet<ManualSort>(
                context: context,
                builder: (_) => _SortSheet(current: sort),
              );
              if (next != null) {
                ref.read(manualSortProvider.notifier).state = next;
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '搜索手册...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                onChanged: (v) => ref.read(manualSearchProvider.notifier).state = v,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(label: '全部', value: ManualFilter.all, current: filter),
                  _Chip(label: '最近', value: ManualFilter.recent, current: filter),
                  _Chip(label: '收藏 ⭐', value: ManualFilter.favorites, current: filter),
                  _Chip(label: '未完成', value: ManualFilter.incomplete, current: filter),
                  ActionChip(
                    avatar: const Icon(Icons.dashboard_customize, size: 16),
                    label: const Text('模板'),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const TemplateManagerPage(),
                    )),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.label_outline, size: 16),
                    label: Text(selectedTagIds.isEmpty ? '标签' : '标签 (${selectedTagIds.length})'),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const TagFilterSheet(),
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.label, size: 16, color: Colors.orange),
                    label: const Text('管理'),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const TagManagerPage(),
                    )),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('加载失败：$e')),
                data: (list) {
                  if (list.isEmpty) {
                    return const EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: '没有匹配的手册',
                      hint: '试试别的搜索词或筛选',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(manualListProvider),
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) => ManualCard(
                        manual: list[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ManualDetailPage(manualId: list[i].id)),
                        ),
                        onToggleFavorite: () => toggleFav(list[i]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const _FabMenu(),
    );
  }
}

Future<void> _showExport(BuildContext context, WidgetRef ref) async {
  final result = await showDialog<ExportResult>(
    context: context,
    builder: (_) => const ExportDialog(),
  );
  if (result == null) return;
  // 写入临时文件并分享。
  final tmp = await getTemporaryDirectory();
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final file = File('${tmp.path}/snapflow_export_$stamp.json');
  await file.writeAsString(result.json);
  await Share.shareXFiles(
    [XFile(file.path)],
    subject: 'SnapFlow 手册导出（${result.count} 本）',
  );
}

class _Chip extends ConsumerWidget {
  final String label;
  final ManualFilter value;
  final ManualFilter current;
  const _Chip({required this.label, required this.value, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = value == current;
    final c = Theme.of(context).colorScheme;
    final sf = Theme.of(context).extension<SnapFlowColors>();
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      selectedColor: c.primary,
      backgroundColor: sf?.muted ?? c.surfaceContainerHighest,
      side: BorderSide(color: selected ? Colors.transparent : (sf?.border ?? c.outlineVariant)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onSelected: (_) => ref.read(manualFilterProvider.notifier).state = value,
    );
  }
}

class _SortSheet extends StatelessWidget {
  final ManualSort current;
  const _SortSheet({required this.current});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(title: Text('排序方式', style: TextStyle(fontWeight: FontWeight.w700))),
          for (final s in ManualSort.values)
            RadioListTile<ManualSort>(
              value: s,
              groupValue: current,
              title: Text(_label(s)),
              onChanged: (v) => Navigator.of(context).pop(v),
            ),
        ],
      ),
    );
  }

  static String _label(ManualSort s) {
    switch (s) {
      case ManualSort.updatedDesc: return '最近更新';
      case ManualSort.createdDesc: return '最近创建';
      case ManualSort.titleAsc: return '标题字母';
      case ManualSort.completionDesc: return '完成度高';
    }
  }
}

/// FAB 菜单：主 FAB + 展开的"空白手册"/"快速拍照"/"从模板新建"。
class _FabMenu extends ConsumerStatefulWidget {
  const _FabMenu();
  @override
  ConsumerState<_FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends ConsumerState<_FabMenu> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_open)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _open = false),
            ),
          ),
        if (_open) ...[
          _FabItem(label: '空白手册', icon: Icons.note_add, onTap: () => _closeAnd(_createBlank)),
          const SizedBox(height: 8),
          _FabItem(label: '快速拍照', icon: Icons.photo_camera, onTap: () => _closeAnd(_quickCapture)),
          const SizedBox(height: 8),
          _FabItem(label: '从模板新建', icon: Icons.dashboard_customize, onTap: () => _closeAnd(_newFromTemplate)),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          heroTag: 'main-fab',
          onPressed: () => setState(() => _open = !_open),
          child: Icon(_open ? Icons.close : Icons.add),
        ),
      ],
    );
  }

  void _closeAnd(Future<void> Function() action) {
    setState(() => _open = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  Future<void> _createBlank() async {
    final ctl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新建空白手册'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '手册标题'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ctl.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (name == null || name.isEmpty) {
      SnapToast.show(context, '已取消', success: false);
      return;
    }
    final repo = await ref.read(manualRepositoryProvider.future);
    final now = DateTime.now();
    final m = Manual(
      id: 'm-${now.millisecondsSinceEpoch}',
      title: name,
      coverImagePath: null,
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
      steps: const [],
    );
    await repo.saveManual(m);
    ref.invalidate(manualListProvider);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ManualDetailPage(manualId: m.id)),
    );
  }

  Future<void> _quickCapture() async {
    final repo = await ref.read(manualRepositoryProvider.future);
    final now = DateTime.now();
    final newStep = Step(
      id: 's-${now.millisecondsSinceEpoch}',
      order: 100,
      title: null, note: '', completed: false, images: const [], optionalFields: const {},
      createdAt: now,
    );
    final m = Manual(
      id: 'm-${now.millisecondsSinceEpoch}',
      title: '新手册',
      coverImagePath: null,
      isFavorite: false,
      createdAt: now, updatedAt: now,
      steps: [newStep],
    );
    await repo.saveManual(m);
    ref.invalidate(manualListProvider);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ManualDetailPage(manualId: m.id, autoCaptureStepId: newStep.id)),
    );
  }

  Future<void> _newFromTemplate() async {
    final t = await showTemplateSheet(context, ref: ref);
    if (t == null || !mounted) return;
    final repo = await ref.read(manualRepositoryProvider.future);
    final now = DateTime.now();
    final steps = [
      for (var i = 0; i < t.steps.length; i++)
        TemplateStepAdapter.fromTemplateStep(t.steps[i], i, now.millisecondsSinceEpoch)
    ];
    final m = Manual(
      id: 'm-${now.millisecondsSinceEpoch}',
      title: t.name,
      coverImagePath: null,
      isFavorite: false,
      createdAt: now, updatedAt: now,
      steps: steps,
    );
    await repo.saveManual(m);
    ref.invalidate(manualListProvider);
    if (!mounted) return;
    SnapToast.show(context, '已基于"${t.name}"创建', success: true);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ManualDetailPage(manualId: m.id)),
    );
  }
}

class _FabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _FabItem({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          elevation: 4,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: 'fab-$label',
          onPressed: onTap,
          child: Icon(icon),
        ),
      ],
    );
  }
}