import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities.dart';

class ManualCard extends StatelessWidget {
  final Manual manual;
  final VoidCallback onTap;
  const ManualCard({super.key, required this.manual, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cover = manual.coverImagePath;
    final df = DateFormat('M月d日');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: cover != null
                      ? Image.file(File(cover), fit: BoxFit.cover)
                      : Container(color: Colors.grey.shade200, child: const Icon(Icons.menu_book)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(manual.title.isEmpty ? '未命名' : manual.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('${manual.steps.length} 步 · ${df.format(manual.updatedAt)}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}