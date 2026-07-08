import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers.dart';
import '../domain/entities.dart';
import 'manual_detail_page.dart';
import 'widgets/manual_card.dart';

final manualListProvider = FutureProvider<List<Manual>>((ref) async {
  final repo = await ref.watch(manualRepositoryProvider.future);
  return repo.listManuals();
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manualsAsync = ref.watch(manualListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的手册')),
      body: manualsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (manuals) {
          if (manuals.isEmpty) {
            return const Center(
              child: Text('还没有手册\n点右下角 [+ ] 创建', textAlign: TextAlign.center),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(manualListProvider),
            child: ListView.builder(
              itemCount: manuals.length,
              itemBuilder: (_, i) => ManualCard(
                manual: manuals[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ManualDetailPage(manualId: manuals[i].id),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onCreate(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _onCreate(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新建手册'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '标题（可空）'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (title == null) return;
    final repo = await ref.read(manualRepositoryProvider.future);
    final now = DateTime.now();
    final manual = Manual(
      id: 'm-${now.millisecondsSinceEpoch}',
      title: title,
      coverImagePath: null,
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
      steps: const [],
    );
    await repo.saveManual(manual);
    ref.invalidate(manualListProvider);
  }
}