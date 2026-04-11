import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ColorConstants.dart';

import 'package:flutter/material.dart';
import '../main.dart';
import 'ColorConstants.dart';

void CustomSnackBar(String msg, String type) {
  final navigator = rootNavigatorKey.currentState;
  if (navigator == null) return;

  final overlay = navigator.overlay;
  if (overlay == null) return;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: MediaQuery.of(overlay.context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: _TopSnackBarWidget(
          msg: msg,
          type: type,
          onDismiss: () => entry.remove(),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(const Duration(seconds: 2), () {
    if (entry.mounted) entry.remove();
  });
}

class _TopSnackBarWidget extends StatelessWidget {
  final String msg;
  final String type;
  final VoidCallback onDismiss;

  const _TopSnackBarWidget({
    required this.msg,
    required this.type,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;

    if (type == "S") {
      bgColor = ColorConstants.greenSecondaryColor;
      icon = Icons.check_circle_rounded;
    } else if (type == "E") {
      bgColor = ColorConstants.error;
      icon = Icons.error_outline_rounded;
    } else {
      bgColor = ColorConstants.orangeOne;
      icon = Icons.warning_amber_rounded;
    }

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: -100.0, end: 0.0),
      builder: (_, value, child) =>
          Transform.translate(offset: Offset(0, value), child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

