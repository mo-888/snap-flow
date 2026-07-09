import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/bottom_sheet.dart';
import '../manual/domain/entities.dart';
import 'template_service.dart';

/// 显示模板选择 sheet，返回选中的模板（null 表示取消）。
/// 用返回值代替 onPick 回调，避免 context 生命周期耦合。
Future<Template?> showTemplateSheet(BuildContext context, {WidgetRef? ref}) async {
  if (ref == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('请在 Riverpod 作用域内调用')),
    );
    return null;
  }
  final db = ref.read(databaseProvider);
  final svc = TemplateService(db: db);
  List<Template> templates;
  try {
    templates = await svc.listTemplates();
  } catch (e) {
    if (!context.mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('加载模板失败：$e')),
    );
    return null;
  }
  if (!context.mounted) return null;
  return SnapSheet.show<Template>(
    context,
    title: '选择模板',
    subtitle: '基于模板快速创建手册',
    child: Material(
      // 单独包 Material，ListTile ink splashes 才能正确显示（不被外层 surface 颜色覆盖）
      color: Colors.transparent,
      child: ListView(
        shrinkWrap: true,
        children: templates.map((t) => ListTile(
          leading: Icon(t.isBuiltin ? Icons.dashboard_customize : Icons.bookmark_added),
          title: Text(t.name),
          subtitle: Text('${t.steps.length} 步 · ${t.description}'),
          onTap: () => Navigator.of(context).pop(t),
        )).toList(),
      ),
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
    createdAt: DateTime.fromMillisecondsSinceEpoch(nowMs),
  );
}