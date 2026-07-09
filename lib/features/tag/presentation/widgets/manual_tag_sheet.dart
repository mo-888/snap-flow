import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers.dart';
import '../../../manual/domain/entities.dart' as domain show Tag;

Future<Set<String>?> showManualTagSheet(
  BuildContext context, {
  required Set<String> initial,
}) async {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ManualTagSheet(initial: initial),
  );
}

class _ManualTagSheet extends ConsumerStatefulWidget {
  final Set<String> initial;
  const _ManualTagSheet({required this.initial});

  @override
  ConsumerState<_ManualTagSheet> createState() => _ManualTagSheetState();
}

class _ManualTagSheetState extends ConsumerState<_ManualTagSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initial};
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(tagsProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('编辑标签', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _selected.clear()),
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
                    child: Text('暂无标签，请先到"标签管理"创建', textAlign: TextAlign.center),
                  );
                }
                return Wrap(
                  spacing: 8, runSpacing: 8,
                  children: tags.map((domain.Tag t) => FilterChip(
                    label: Text(t.name),
                    selected: _selected.contains(t.id),
                    onSelected: (on) => setState(() {
                      if (on) {
                        _selected.add(t.id);
                      } else {
                        _selected.remove(t.id);
                      }
                    }),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_selected),
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }
}
