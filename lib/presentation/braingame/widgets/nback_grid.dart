// widget 3x3 grid untuk dual n-back
import 'package:flutter/material.dart';

class NBackGrid extends StatelessWidget {
  final int? activePosition; // 0-8, null = tidak ada yang aktif
  final bool isPlaying;

  const NBackGrid({super.key, this.activePosition, this.isPlaying = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final gridSize = (screenWidth - 80).clamp(240.0, 320.0);

    return SizedBox(
      width: gridSize,
      height: gridSize,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 9,
        itemBuilder: (context, index) => _buildBlock(index, isDark),
      ),
    );
  }

  Widget _buildBlock(int index, bool isDark) {
    final isActive = activePosition == index && isPlaying;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive
            ? const Color(0xFF1976D2)
            : (isDark ? const Color(0xFF1E1E2E) : Colors.grey.shade200),
        border: Border.all(
          color: isActive
              ? const Color(0xFF1565C0)
              : (isDark ? Colors.white12 : Colors.grey.shade300),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF1976D2).withValues(alpha: 0.4),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
    );
  }
}
