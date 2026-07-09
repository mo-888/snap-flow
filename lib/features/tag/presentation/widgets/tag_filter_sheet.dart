import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers.dart';
import '../../../manual/domain/entities.dart' as domain show Tag;

/// 多选标签筛选 sheet
class TagFilterSheet extends ConsumerWidget {
  const TagFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tagsProvider);
    final selected = ref.watch(selectedTagIdsProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('按标签筛选', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      ref.read(selectedTagIdsProvider.notifier).state = <String>{},
                  child: const Text('清空'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('加载失败：$e'),
              data: (tags) {
                if (tags.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('暂无标签，先到"管理标签"创建', textAlign: TextAlign.center),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((domain.Tag t) => FilterChip(
                    label: Text(t.name),
                    selected: selected.contains(t.id),
                    onSelected: (on) {
                      final next = {...selected};
                      if (on) {
                        next.add(t.id);
                      } else {
                        next.remove(t.id);
                      }
                      ref.read(selectedTagIdsProvider.notifier).state = next;
                    },
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }
}