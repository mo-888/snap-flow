import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/bottom_sheet.dart';
import '../manual/domain/entities.dart';
import 'template_service.dart';

enum TemplateChoice { blank, quickCapture, fromTemplate }

class TemplatePickResult {
  final TemplateChoice choice;
  final Template? template;
  const TemplatePickResult._(this.choice, this.template);
  factory TemplatePickResult.blank() => const TemplatePickResult._(TemplateChoice.blank, null);
  factory TemplatePickResult.quickCapture() => const TemplatePickResult._(TemplateChoice.quickCapture, null);
  factory TemplatePickResult.fromTemplate(Template t) => TemplatePickResult._(TemplateChoice.fromTemplate, t);
}

/// 显示统一的"新建手册"选择 sheet：空白手册 / 快速拍照 / 从模板新建。
Future<TemplatePickResult?> showTemplateSheet(BuildContext context, {WidgetRef? ref}) async {
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
  return SnapSheet.show<TemplatePickResult>(
    context,
    title: '新建手册',
    subtitle: '从模板快速创建或拍下当前画面',
    child: Material(
      color: Colors.transparent,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.note_add),
            title: const Text('空白手册'),
            subtitle: const Text('先起个标题，后面随时加步骤'),
            onTap: () => Navigator.of(context).pop(TemplatePickResult.blank()),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('快速拍照'),
            subtitle: const Text('拍一张立即记录'),
            onTap: () => Navigator.of(context).pop(TemplatePickResult.quickCapture()),
          ),
          const Divider(height: 1),
          for (final t in templates) ListTile(
            leading: Icon(t.isBuiltin ? Icons.dashboard_customize : Icons.bookmark_added),
            title: Text(t.name),
            subtitle: Text('${t.steps.length} 步 · ${t.description}'),
            onTap: () => Navigator.of(context).pop(TemplatePickResult.fromTemplate(t)),
          ),
        ],
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
