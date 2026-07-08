import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/snap_toast.dart';
import '../../template/template_sheet.dart';
import '../domain/entities.dart';
import 'manual_detail_page.dart';
import 'widgets/manual_card.dart';

enum ManualFilter { all, recent, favorites, templates, incomplete }

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
        case ManualFilter.templates: return m.steps.length > 2;
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
                  IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
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
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _Chip(label: '全部', value: ManualFilter.all, current: filter, ref: ref),
                  _Chip(label: '最近', value: ManualFilter.recent, current: filter, ref: ref),
                  _Chip(label: '收藏 ⭐', value: ManualFilter.favorites, current: filter, ref: ref),
                  _Chip(label: '模板', value: ManualFilter.templates, current: filter, ref: ref),
                  _Chip(label: '未完成', value: ManualFilter.incomplete, current: filter, ref: ref),
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
      floatingActionButton: _FabMenu(ref: ref),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final ManualFilter value;
  final ManualFilter current;
  final WidgetRef ref;
  const _Chip({required this.label, required this.value, required this.current, required this.ref});

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => ref.read(manualFilterProvider.notifier).state = value,
      ),
    );
  }
}

class _FabMenu extends StatefulWidget {
  final WidgetRef ref;
  const _FabMenu({required this.ref});
  @override
  State<_FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<_FabMenu> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_open) Positioned.fill(child: GestureDetector(onTap: () => setState(() => _open = false))),
        if (_open) ...[
          _FabItem(label: '快速拍照', icon: Icons.photo_camera, onTap: () { setState(() => _open = false); }),
          const SizedBox(height: 8),
          _FabItem(label: '从模板新建', icon: Icons.dashboard_customize, onTap: () { setState(() => _open = false); _newFromTemplate(context, widget.ref); }),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          onPressed: () => setState(() => _open = !_open),
          child: Icon(_open ? Icons.close : Icons.add),
        ),
      ],
    );
  }

  Future<void> _newFromTemplate(BuildContext context, WidgetRef ref) async {
    await showTemplateSheet(context, ref, onPick: (t) async {
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
      if (context.mounted) {
        SnapToast.show(context, '已基于"${t.name}"创建', success: true);
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManualDetailPage(manualId: m.id)));
      }
    });
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          child: Icon(icon),
        ),
      ],
    );
  }
}