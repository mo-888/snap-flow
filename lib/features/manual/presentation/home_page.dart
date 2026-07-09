import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/snap_toast.dart';
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
  return async.whenData((list) {
    return list.where((m) {
      if (q.isNotEmpty && !m.title.toLowerCase().contains(q)) return false;
      switch (filter) {
        case ManualFilter.all: return true;
        case ManualFilter.favorites: return m.isFavorite;
        case ManualFilter.incomplete:
          return m.steps.isNotEmpty && m.steps.any((s) => !s.completed);
        case ManualFilter.recent:
          return m.updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 7)));
      }
    }).toList();
  });
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredManualsProvider);
    final filter = ref.watch(manualFilterProvider);

    Future<void> toggleFav(Manual m) async {
      final repo = await ref.read(manualRepositoryProvider.future);
      await repo.saveManual(m.copyWith(isFavorite: !m.isFavorite));
      ref.invalidate(manualListProvider);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('我的手册', style: Theme.of(context).textTheme.headlineSmall),
                  ),
                ],
              ),
            ),
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
            // Wrap 自适应换行，避免横向 ListView 在窄屏挤压
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

class _Chip extends ConsumerWidget {
  final String label;
  final ManualFilter value;
  final ManualFilter current;
  const _Chip({required this.label, required this.value, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = value == current;
    final c = Theme.of(context).colorScheme;
    final sf = Theme.of(context).extension<SnapFlowColors>(); // optional
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

/// FAB 菜单：主 FAB + 展开的"快速拍照"/"从模板新建"。
/// 使用 ConsumerStatefulWidget 而非持有 WidgetRef 字段，避免 ref 跨重建失效。
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
          _FabItem(
            label: '快速拍照',
            icon: Icons.photo_camera,
            onTap: () => _closeAnd(_quickCapture),
          ),
          const SizedBox(height: 8),
          _FabItem(
            label: '从模板新建',
            icon: Icons.dashboard_customize,
            onTap: () => _closeAnd(_newFromTemplate),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          heroTag: 'main-fab', // 避免与小 FAB 冲突
          onPressed: () => setState(() => _open = !_open),
          child: Icon(_open ? Icons.close : Icons.add),
        ),
      ],
    );
  }

  /// 关闭菜单，延迟到下一帧再执行回调，避免 setState 重建与导航竞争。
  void _closeAnd(Future<void> Function() action) {
    setState(() => _open = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  /// 创建空手册 → 进 detail → 自动加第一步 → 调起相机。
  Future<void> _quickCapture() async {
    final repo = await ref.read(manualRepositoryProvider.future);
    final now = DateTime.now();
    final newStep = Step(
      id: 's-${now.millisecondsSinceEpoch}',
      order: 100,
      title: null, note: '', completed: false, images: const [], optionalFields: const {},
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

  /// 打开模板 sheet → 选中后创建手册 → 进 detail。
  Future<void> _newFromTemplate() async {
    final t = await showTemplateSheet(context);
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
        // Label 区域也可点击：解决用户点文字"无效果"的问题
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