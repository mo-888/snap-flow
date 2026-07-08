import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities.dart';

class ThumbGrid extends StatelessWidget {
  final List<StepImage> images;
  final void Function(int index) onTap;
  final void Function(int index) onDelete;

  const ThumbGrid({
    super.key,
    required this.images,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('还没有图片'),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (_, i) {
        final img = images[i];
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => onTap(i),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(img.thumbnailPath), fit: BoxFit.cover),
                ),
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: IconButton.filledTonal(
                iconSize: 18,
                onPressed: () => onDelete(i),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        );
      },
    );
  }
}