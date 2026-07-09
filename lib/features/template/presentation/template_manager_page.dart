import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/providers.dart';
import '../template_service.dart';

const _uuid = Uuid();

final _templateServiceProvider = Provider<TemplateService>((ref) {
  final db = ref.watch(databaseProvider);
  return TemplateService(db: db);
});

final _allTemplatesProvider = FutureProvider<List<Template>>((ref) async {
  final svc = ref.watch(_templateServiceProvider);
  return svc.listTemplates();
});

class TemplateManagerPage extends ConsumerWidget {
  const TemplateManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_allTemplatesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理模板'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新建模板',
            onPressed: () => _editTemplateDialog(context, ref, null),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (templates) {
          if (templates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('暂无模板', textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.separated(
            itemCount: templates.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final t = templates[i];
              return ListTile(
                leading: Icon(t.isBuiltin ? Icons.dashboard_customize : Icons.bookmark_added),
                title: Row(
                  children: [
                    Expanded(child: Text(t.name)),
                    if (t.isBuiltin)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text('内置', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ),
                  ],
                ),
                subtitle: Text('${t.steps.length} 步 · ${t.description}'),
                trailing: t.isBuiltin
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _editTemplateDialog(context, ref, t),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('删除模板？'),
                                  content: Text('"${t.name}" 将被删除'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('取消')),
                                    FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('删除')),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await ref.read(_templateServiceProvider).deleteUserTemplate(t.id);
                                ref.invalidate(_allTemplatesProvider);
                              }
                            },
                          ),
                        ],
                      ),
                onTap: t.isBuiltin ? null : () => _editTemplateDialog(context, ref, t),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editTemplateDialog(BuildContext context, WidgetRef ref, Template? existing) async {
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final descCtl = TextEditingController(text: existing?.description ?? '');
    final stepCtls = <TextEditingController>[
      for (final s in existing?.steps ?? const <TemplateStep>[]) TextEditingController(text: s.title),
    ];
    if (stepCtls.isEmpty) stepCtls.add(TextEditingController());

    final result = await showDialog<Template?>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setLocal) => AlertDialog(
        title: Text(existing == null ? '新建模板' : '编辑模板'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameCtl,
                  decoration: const InputDecoration(labelText: '模板名'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtl,
                  decoration: const InputDecoration(labelText: '描述'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('步骤', style: TextStyle(fontWeight: FontWeight.w700)),
                    TextButton.icon(
                      onPressed: () => setLocal(() => stepCtls.add(TextEditingController())),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('加步骤'),
                    ),
                  ],
                ),
                for (var i = 0; i < stepCtls.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(child: TextField(controller: stepCtls[i], decoration: InputDecoration(hintText: '步骤 ${i + 1}', isDense: true))),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.red),
                          onPressed: stepCtls.length == 1 ? null : () => setLocal(() => stepCtls.removeAt(i)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final name = nameCtl.text.trim();
              if (name.isEmpty) return;
              final steps = stepCtls
                  .map((c) => c.text.trim())
                  .where((s) => s.isNotEmpty)
                  .map((s) => TemplateStep(title: s, fields: const {}))
                  .toList();
              Navigator.of(ctx).pop(Template(
                id: existing?.id ?? _uuid.v4(),
                name: name,
                description: descCtl.text.trim(),
                steps: steps,
                isBuiltin: false,
              ));
            },
            child: const Text('保存'),
          ),
        ],
      )),
    );
    if (result == null) return;
    await ref.read(_templateServiceProvider).saveUserTemplate(result);
    ref.invalidate(_allTemplatesProvider);
  }
}