import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../domain/entities.dart' as domain;

class StepTile extends StatelessWidget {
  final int index;
  final domain.Step step;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onToggleComplete;

  const StepTile({
    super.key,
    required this.index,
    required this.step,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final sf = Theme.of(context).extension<SnapFlowColors>()!;
    final hasNote = step.note.trim().isNotEmpty;
    final fieldCount = step.optionalFields.length;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        leading: CircleAvatar(
          backgroundColor: step.completed ? c.surfaceContainerHighest : c.primary,
          foregroundColor: step.completed ? c.outline : c.onPrimary,
          child: Text(step.completed ? '✓' : '${index + 1}'),
        ),
        title: Text(step.title?.isNotEmpty == true ? step.title! : '未命名步骤',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(children: [
            Text('${step.images.length} 图', style: TextStyle(color: c.outline, fontSize: 12)),
            if (hasNote) ...[const SizedBox(width: 8), Text('有说明', style: TextStyle(color: c.outline, fontSize: 12))],
            if (fieldCount > 0) ...[const SizedBox(width: 8), Text('$fieldCount 字段', style: TextStyle(color: c.outline, fontSize: 12))],
          ]),
        ),
        children: [
          if (step.images.isNotEmpty)
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: step.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(step.images[i].thumbnailPath), width: 72, height: 72, fit: BoxFit.cover),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(step.note.isEmpty ? '暂无说明...' : step.note,
                  style: TextStyle(color: hasNote ? c.onSurface : c.outline, fontStyle: hasNote ? FontStyle.normal : FontStyle.italic)),
            ),
          ),
          if (fieldCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: step.optionalFields.entries.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: sf.surface2, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: TextStyle(color: c.outline, fontSize: 12)),
                      Text(e.value.isEmpty ? '—' : e.value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                    ],
                  ),
                )).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                _Action(icon: step.completed ? Icons.refresh : Icons.check, label: step.completed ? '重做' : '完成', onTap: onToggleComplete),
                _Action(icon: Icons.edit, label: '编辑', onTap: onEdit),
                _Action(icon: Icons.copy, label: '复制', onTap: onDuplicate),
                _Action(icon: Icons.delete_outline, label: '删除', onTap: onDelete, danger: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _Action({required this.icon, required this.label, required this.onTap, this.danger = false});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: danger ? c.error : c.primary),
        label: Text(label, style: TextStyle(color: danger ? c.error : c.primary, fontSize: 12)),
      ),
    );
  }
}
