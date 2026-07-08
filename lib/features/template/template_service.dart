import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Template {
  final String id;
  final String name;
  final String description;
  final List<TemplateStep> steps;

  const Template({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
  });
}

class TemplateStep {
  final String title;
  final Map<String, String> fields;
  const TemplateStep({required this.title, required this.fields});
}

class TemplateService {
  static const _path = 'assets/templates/builtin_templates.json';

  Future<List<Template>> listTemplates() async {
    final raw = await rootBundle.loadString(_path);
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(_parse).toList();
  }

  Template _parse(Map<String, dynamic> m) {
    return Template(
      id: m['id'] as String,
      name: m['name'] as String,
      description: m['description'] as String,
      steps: (m['steps'] as List).map((s) {
        return TemplateStep(
          title: s['title'] as String,
          fields: Map<String, String>.from(s['fields'] as Map),
        );
      }).toList(),
    );
  }
}