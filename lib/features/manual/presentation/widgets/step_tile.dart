import 'package:flutter/material.dart';
import '../../domain/entities.dart' as domain;

class StepTile extends StatelessWidget {
  final domain.Step step;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const StepTile({
    super.key,
    required this.step,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text('${(step.order / 100).round()}')),
        title: Text(step.title?.isNotEmpty == true ? step.title! : '(无标题)'),
        subtitle: Text(step.note.isEmpty ? '(无说明)' : step.note, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${step.images.length} 图'),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}