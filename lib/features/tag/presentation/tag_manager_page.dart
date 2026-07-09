import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/providers.dart';
import '../../manual/domain/entities.dart' as domain show Tag;
import '../../manual/presentation/home_page.dart' show manualListProvider;

const _uuid = Uuid();

class TagManagerPage extends ConsumerWidget {
  const TagManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tagsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理标签'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新建标签',
            onPressed: () => _editDialog(context, ref, null),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (tags) {
          if (tags.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('暂无标签，点击右上角 + 创建', textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.separated(
            itemCount: tags.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => ListTile(
              leading: const Icon(Icons.label_outline),
              title: Text(tags[i].name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _editDialog(context, ref, tags[i]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('删除标签？'),
                          content: Text('将解除所有手册与"${tags[i].name}"的关联'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('取消')),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('删除'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        final repo = await ref.read(manualRepositoryProvider.future);
                        await repo.deleteTag(tags[i].id);
                        ref.invalidate(tagsProvider);
                        ref.invalidate(manualListProvider);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _editDialog(BuildContext context, WidgetRef ref, domain.Tag? existing) async {
    final ctl = TextEditingController(text: existing?.name ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? '新建标签' : '重命名标签'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '标签名'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final name = ctl.text.trim();
              if (name.isEmpty) return;
              Navigator.of(context).pop(name);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    final repo = await ref.read(manualRepositoryProvider.future);
    final tag = existing?.copyWith(name: result) ??
        domain.Tag(id: _uuid.v4(), name: result, createdAt: DateTime.now());
    await repo.saveTag(tag);
    ref.invalidate(tagsProvider);
    ref.invalidate(manualListProvider);
  }
}