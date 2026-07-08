import 'package:flutter/material.dart';

/// Modal bottom sheet matching ui/index.html .sheet — rounded top 24, drag handle.
class SnapSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const SnapSheet({super.key, required this.title, this.subtitle, required this.child});

  static Future<T?> show<T>(BuildContext context, {required Widget child, String title = '', String? subtitle}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SnapSheet(title: title, subtitle: subtitle, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: c.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(subtitle!, style: TextStyle(color: c.outline, fontSize: 13)),
            ),
          Flexible(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}