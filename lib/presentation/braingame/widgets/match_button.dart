// tombol match untuk position dan sound
import 'package:flutter/material.dart';

class MatchButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPressed;
  final bool? isCorrect; // null = belum ada feedback, true = benar, false = salah
  final VoidCallback onPressed;

  const MatchButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isPressed,
    required this.isCorrect,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color borderColor;
    Color iconColor;

    if (isCorrect != null) {
      if (isCorrect!) {
        bgColor = const Color(0xFF2E7D32).withValues(alpha: 0.15);
        borderColor = const Color(0xFF2E7D32);
        iconColor = const Color(0xFF2E7D32);
      } else {
        bgColor = const Color(0xFFD32F2F).withValues(alpha: 0.15);
        borderColor = const Color(0xFFD32F2F);
        iconColor = const Color(0xFFD32F2F);
      }
    } else if (isPressed) {
      bgColor = const Color(0xFF1976D2).withValues(alpha: 0.2);
      borderColor = const Color(0xFF1976D2);
      iconColor = const Color(0xFF1976D2);
    } else {
      bgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
      borderColor = isDark ? Colors.white24 : Colors.grey.shade300;
      iconColor = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 30),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCorrect != null
                        ? (isCorrect! ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F))
                        : (isDark ? Colors.white : Colors.black87),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
