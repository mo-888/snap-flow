import 'dart:async';
import 'package:flutter/material.dart';

/// Singleton toast — matches ui/index.html toast at top:60px, slides down.
class SnapToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(BuildContext context, String message, {bool error = false, bool success = false}) {
    _entry?.remove();
    _timer?.cancel();
    final overlay = Overlay.of(context, rootOverlay: true);
    final colorScheme = Theme.of(context).colorScheme;
    final bg = error
        ? colorScheme.error
        : success
            ? colorScheme.primary
            : const Color(0xFF0F172A);
    _entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 60,
        left: 0, right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black26)],
              ),
              child: Text(message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_entry!);
    _timer = Timer(const Duration(milliseconds: 2400), () {
      _entry?.remove();
      _entry = null;
    });
  }
}