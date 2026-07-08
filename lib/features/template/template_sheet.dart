import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/bottom_sheet.dart';
import '../manual/domain/entities.dart';
import 'template_service.dart';

Future<void> showTemplateSheet(BuildContext context, WidgetRef ref, {required void Function(Template) onPick}) async {
  final svc = TemplateService();
  final templates = await svc.listTemplates();
  if (!context.mounted) return;
  await SnapSheet.show(
    context,
    title: '选择模板',
    subtitle: '基于模板快速创建手册',
    child: Column(
      children: templates.map((t) => ListTile(
        leading: const Icon(Icons.dashboard_customize),
        title: Text(t.name),
        subtitle: Text('${t.steps.length} 步 · ${t.description}'),
        onTap: () { Navigator.of(context).pop(); onPick(t); },
      )).toList(),
    ),
  );
}

class TemplateStepAdapter {
  static Step fromTemplateStep(TemplateStep ts, int i, int nowMs) => Step(
    id: 's-$nowMs-$i',
    order: (i + 1) * 100,
    title: ts.title,
    note: '',
    completed: false,
    images: const [],
    optionalFields: ts.fields,
  );
}
