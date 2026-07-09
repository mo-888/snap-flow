import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart' show Value;
import '../../core/db/database.dart';

class Template {
  final String id;
  final String name;
  final String description;
  final List<TemplateStep> steps;
  final bool isBuiltin;

  const Template({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    this.isBuiltin = false,
  });
}

class TemplateStep {
  final String title;
  final Map<String, String> fields;
  const TemplateStep({required this.title, required this.fields});
}

class TemplateService {
  static const _path = 'assets/templates/builtin_templates.json';
  final AppDatabase db;
  TemplateService({required this.db});

  Future<List<Template>> listTemplates() async {
    final builtin = await _loadBuiltin();
    final userRows = await db.select(db.userTemplates).get();
    final user = userRows.map(_rowToTemplate).toList();
    return [...builtin, ...user];
  }

  Future<List<Template>> listBuiltin() => _loadBuiltin();

  Future<List<Template>> listUser() async {
    final rows = await db.select(db.userTemplates).get();
    return rows.map(_rowToTemplate).toList();
  }

  Template _rowToTemplate(UserTemplate row) {
    final stepsJson = jsonDecode(row.stepsJson) as List;
    return Template(
      id: row.id,
      name: row.name,
      description: row.description,
      steps: stepsJson.map((s) {
        final m = s as Map<String, dynamic>;
        return TemplateStep(
          title: m['title'] as String,
          fields: Map<String, String>.from(m['fields'] as Map),
        );
      }).toList(),
    );
  }

  Future<void> saveUserTemplate(Template t) async {
    final stepsJson = jsonEncode(
      t.steps.map((s) => {'title': s.title, 'fields': s.fields}).toList(),
    );
    await db.into(db.userTemplates).insertOnConflictUpdate(
          UserTemplatesCompanion.insert(
            id: t.id,
            name: t.name,
            description: Value(t.description),
            stepsJson: stepsJson,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> deleteUserTemplate(String id) async {
    await (db.delete(db.userTemplates)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Template>> _loadBuiltin() async {
    final raw = await rootBundle.loadString(_path);
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list
        .map((m) => Template(
              id: m['id'] as String,
              name: m['name'] as String,
              description: m['description'] as String,
              isBuiltin: true,
              steps: (m['steps'] as List).map((s) {
                return TemplateStep(
                  title: s['title'] as String,
                  fields: Map<String, String>.from(s['fields'] as Map),
                );
              }).toList(),
            ))
        .toList();
  }
}