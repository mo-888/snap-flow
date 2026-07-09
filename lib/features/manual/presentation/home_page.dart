import 'dart:io';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/snap_toast.dart';
import '../../import_export/presentation/export_dialog.dart';
import '../../import_export/presentation/import_dialog.dart';
import '../../tag/presentation/tag_manager_page.dart';
import '../../template/presentation/template_manager_page.dart';
import '../../template/template_sheet.dart' show showTemplateSheet, TemplateChoice, TemplateStepAdapter;
import '../../template/template_service.dart' show Template;
import '../domain/entities.dart';
import 'manual_detail_page.dart';
import 'widgets/filter_grid_button.dart';
import 'widgets/manual_card.dart';

enum ManualFilter { all, recent, favorites, incomplete }

IconData _iconFor(ManualFilter f) {
  switch (f) {
    case ManualFilter.all: return Icons.menu_book;
    case ManualFilter.recent: return Icons.schedule;
    case ManualFilter.favorites: return Icons.star;
    case ManualFilter.incomplete: return Icons.check_box_outline_blank;
  }
}

String _labelFor(ManualFilter f) {
  switch (f) {
    case ManualFilter.all: return '全部';
    case ManualFilter.recent: return '最近';
    case ManualFilter.favorites: return '收藏 ⭐';
    case ManualFilter.incomplete: return '未完成';
  }
}

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
    final asyncTags = ref.watch(tagsProvider);

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
              child: () {
                final navItems = <Widget>[
                  FilterGridButton(icon: Icons.dashboard_customize, label: '模板管理',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const TemplateManagerPage()))),
                  FilterGridButton(icon: Icons.label, label: '标签管理',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const TagManagerPage()))),
                ];
                final filterItems = <Widget>[
                  for (final f in ManualFilter.values)
                    FilterGridButton(
                      icon: _iconFor(f),
                      label: _labelFor(f),
                      selected: filter == f,
                      onTap: () => ref.read(manualFilterProvider.notifier).state = f,
                    ),
                ];
                final tagItems = asyncTags.maybeWhen(
                  data: (tags) => <Widget>[
                    for (final t in tags)
                      FilterGridButton(
                        icon: Icons.label,
                        label: t.name,
                        selected: selectedTagIds.contains(t.id),
                        onTap: () {
                          final current = ref.read(selectedTagIdsProvider);
                          final next = {...current};
                          if (next.contains(t.id)) {
                            next.remove(t.id);
                          } else {
                            next.add(t.id);
                          }
                          ref.read(selectedTagIdsProvider.notifier).state = next;
                        },
                      ),
                  ],
                  orElse: () => <Widget>[],
                );
                return LayoutBuilder(
                  builder: (_, c) {
                    final cols = c.maxWidth < 360 ? 3 : 4;
                    final cellW = (c.maxWidth - (cols - 1) * 8) / cols;
                    return Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        for (final w in navItems) SizedBox(width: cellW, child: w),
                        for (final w in filterItems) SizedBox(width: cellW, child: w),
                        for (final w in tagItems) SizedBox(width: cellW, child: w),
                      ],
                    );
                  },
                );
              }(),
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
      floatingActionButton: const _Fab(),
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
          RadioGroup<ManualSort>(
            groupValue: current,
            onChanged: (v) {
              if (v != null) Navigator.of(context).pop(v);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final s in ManualSort.values)
                  RadioListTile<ManualSort>(
                    value: s,
                    title: Text(_label(s)),
                  ),
              ],
            ),
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

Future<void> _createBlank(BuildContext context, WidgetRef ref) async {
  final ctl = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('新建空白手册'),
      content: TextField(
        controller: ctl, autofocus: true,
        decoration: const InputDecoration(hintText: '手册标题'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
        FilledButton(onPressed: () => Navigator.of(context).pop(ctl.text.trim()), child: const Text('创建')),
      ],
    ),
  );
  if (!context.mounted) return;
  if (name == null || name.isEmpty) {
    SnapToast.show(context, '已取消', success: false);
    return;
  }
  final repo = await ref.read(manualRepositoryProvider.future);
  final now = DateTime.now();
  final m = Manual(
    id: 'm-${now.millisecondsSinceEpoch}',
    title: name, coverImagePath: null, isFavorite: false,
    createdAt: now, updatedAt: now, steps: const [],
  );
  await repo.saveManual(m);
  ref.invalidate(manualListProvider);
  if (!context.mounted) return;
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManualDetailPage(manualId: m.id)));
}

Future<void> _quickCapture(BuildContext context, WidgetRef ref) async {
  final repo = await ref.read(manualRepositoryProvider.future);
  final now = DateTime.now();
  final newStep = Step(
    id: 's-${now.millisecondsSinceEpoch}', order: 100,
    title: null, note: '', completed: false, images: const [], optionalFields: const {},
    createdAt: now,
  );
  final m = Manual(
    id: 'm-${now.millisecondsSinceEpoch}',
    title: '新手册', coverImagePath: null, isFavorite: false,
    createdAt: now, updatedAt: now, steps: [newStep],
  );
  await repo.saveManual(m);
  ref.invalidate(manualListProvider);
  if (!context.mounted) return;
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => ManualDetailPage(manualId: m.id, autoCaptureStepId: newStep.id)));
}

Future<void> _newFromTemplate(BuildContext context, WidgetRef ref, Template t) async {
  final repo = await ref.read(manualRepositoryProvider.future);
  final now = DateTime.now();
  final steps = [
    for (var i = 0; i < t.steps.length; i++)
      TemplateStepAdapter.fromTemplateStep(t.steps[i], i, now.millisecondsSinceEpoch)
  ];
  final m = Manual(
    id: 'm-${now.millisecondsSinceEpoch}',
    title: t.name, coverImagePath: null, isFavorite: false,
    createdAt: now, updatedAt: now, steps: steps,
  );
  await repo.saveManual(m);
  ref.invalidate(manualListProvider);
  if (!context.mounted) return;
  SnapToast.show(context, '已基于"${t.name}"创建', success: true);
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManualDetailPage(manualId: m.id)));
}

class _Fab extends ConsumerWidget {
  const _Fab();

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final pick = await showTemplateSheet(context, ref: ref);
    if (pick == null || !context.mounted) return;
    switch (pick.choice) {
      case TemplateChoice.blank:
        return _createBlank(context, ref);
      case TemplateChoice.quickCapture:
        return _quickCapture(context, ref);
      case TemplateChoice.fromTemplate:
        if (pick.template != null) return _newFromTemplate(context, ref, pick.template!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      heroTag: 'main-fab',
      onPressed: () => _open(context, ref),
      child: const Icon(Icons.add),
    );
  }
}