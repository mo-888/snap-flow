import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers.dart';
import '../../template/template_service.dart';
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
    final mode = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('新建手册'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'blank'),
            child: const Text('空白手册'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'template'),
            child: const Text('从模板新建'),
          ),
        ],
      ),
    );
    if (mode == null) return;

    String? title;
    if (mode == 'blank') {
      if (!context.mounted) return;
      final ctl = TextEditingController();
      // ignore: use_build_context_synchronously
      title = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('标题'),
          content: TextField(controller: ctl, autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            FilledButton(
              onPressed: () => Navigator.pop(context, ctl.text),
              child: const Text('创建'),
            ),
          ],
        ),
      );
      if (title == null) return;
    } else {
      final svc = TemplateService();
      final templates = await svc.listTemplates();
      if (!context.mounted) return;
      final picked = await showDialog<Template>(
        context: context,
        builder: (_) => SimpleDialog(
          title: const Text('选择模板'),
          children: templates
              .map((t) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, t),
                    child: Text('${t.name}  (${t.steps.length} 步)'),
                  ))
              .toList(),
        ),
      );
      if (picked == null) return;
      await _createFromTemplate(ref, picked);
      return;
    }

    final repo = await ref.read(manualRepositoryProvider.future);
    final now = DateTime.now();
    await repo.saveManual(Manual(
      id: 'm-${now.millisecondsSinceEpoch}',
      title: title,
      coverImagePath: null,
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
      steps: const [],
    ));
    ref.invalidate(manualListProvider);
  }

  Future<void> _createFromTemplate(WidgetRef ref, Template t) async {
    final repo = await ref.read(manualRepositoryProvider.future);
    final now = DateTime.now();
    final steps = <Step>[];
    for (var i = 0; i < t.steps.length; i++) {
      final ts = t.steps[i];
      steps.add(Step(
        id: 's-${now.millisecondsSinceEpoch}-$i',
        order: (i + 1) * 100,
        title: ts.title,
        note: '',
        completed: false,
        images: const [],
        optionalFields: ts.fields,
      ));
    }
    await repo.saveManual(Manual(
      id: 'm-${now.millisecondsSinceEpoch}',
      title: t.name,
      coverImagePath: null,
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
      steps: steps,
    ));
    ref.invalidate(manualListProvider);
  }
}