import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? hint;
  const EmptyState({super.key, required this.icon, required this.title, this.hint});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: c.outline.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (hint != null) ...[
              const SizedBox(height: 6),
              Text(hint!, style: TextStyle(color: c.outline), textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}