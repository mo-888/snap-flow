import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities.dart';

class ManualCard extends StatelessWidget {
  final Manual manual;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;

  const ManualCard({
    super.key,
    required this.manual,
    required this.onTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final stepCount = manual.steps.length;
    final doneCount = manual.steps.where((s) => s.completed).length;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 80, height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: manual.coverImagePath != null
                          ? Image.file(File(manual.coverImagePath!), fit: BoxFit.cover)
                          : Container(
                              color: c.surfaceContainerHighest,
                              child: Icon(Icons.menu_book, color: c.outline),
                            ),
                    ),
                  ),
                  if (stepCount > 0)
                    Positioned(
                      right: 4, top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$doneCount/$stepCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      if (manual.isFavorite) const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Text('⭐', style: TextStyle(fontSize: 14)),
                      ),
                      Expanded(
                        child: Text(manual.title.isEmpty ? '未命名' : manual.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text('${manual.steps.length} 步 · ${DateFormat('M月d日').format(manual.updatedAt)}',
                        style: TextStyle(color: c.outline, fontSize: 12)),
                  ],
                ),
              ),
              if (onToggleFavorite != null)
                IconButton(
                  icon: Icon(manual.isFavorite ? Icons.star : Icons.star_border,
                      color: manual.isFavorite ? c.tertiary : c.outline),
                  onPressed: onToggleFavorite,
                ),
            ],
          ),
        ),
      ),
    );
  }
}