import 'package:flutter/material.dart';

class SnapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  const SnapIconButton({super.key, required this.icon, this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36, height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}