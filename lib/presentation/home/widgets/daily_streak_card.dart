import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/history_provider.dart';
import '../../../core/providers/settings_provider.dart';

class DailyStreakCard extends StatelessWidget {
  const DailyStreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final lang = settingsProvider.settings.language;
    final isIndo = lang == 'Indonesian';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentStreak = historyProvider.currentStreak;
    final bestStreak = historyProvider.bestStreak;
    final isPracticedToday = historyProvider.isPracticedToday;
    final week = historyProvider.getCurrentWeekStreak(lang);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Streak Counter & Rekor
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFFF6D00),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isIndo ? 'Latihan Harian' : 'Daily Practice',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        isIndo
                            ? 'Rekor: $bestStreak hari'
                            : 'Best: $bestStreak days',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9100), Color(0xFFFF3D00)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3D00).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: Colors.white, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      '$currentStreak ${isIndo ? "Hari" : "Days"}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 7-day row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: week.map((day) {
              return _buildDayItem(day, isDark);
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Motivation message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isPracticedToday
                  ? (isDark ? const Color(0xFF143E1F) : const Color(0xFFE8F5E9))
                  : (isDark ? const Color(0xFF262638) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isPracticedToday ? Icons.check_circle : Icons.tips_and_updates,
                  size: 14,
                  color: isPracticedToday
                      ? const Color(0xFF4CAF50)
                      : (isDark ? const Color(0xFFFFB74D) : const Color(0xFFF57C00)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isPracticedToday
                        ? (isIndo
                            ? 'Latihan hari ini tuntas! Streak Anda bertambah 🔥'
                            : 'Today\'s practice completed! Streak extended 🔥')
                        : (isIndo
                            ? 'Yuk mainkan 1 latihan hari ini untuk menjaga streak! 🎯'
                            : 'Complete 1 practice today to keep your streak! 🎯'),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isPracticedToday
                          ? (isDark ? Colors.green.shade300 : const Color(0xFF2E7D32))
                          : (isDark ? Colors.grey.shade300 : const Color(0xFF475569)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(StreakDayInfo day, bool isDark) {
    Color circleColor;
    Color borderColor;
    Widget innerContent;

    if (day.isPracticed) {
      // Completed: Green with checkmark
      circleColor = const Color(0xFF4CAF50);
      borderColor = const Color(0xFF388E3C);
      innerContent = const Icon(Icons.check, size: 16, color: Colors.white);
    } else if (day.isToday) {
      // Today not practiced yet: outlined dashed / highlighted
      circleColor = isDark ? const Color(0xFF2A2A3E) : const Color(0xFFFEF3C7);
      borderColor = const Color(0xFFFF9800);
      innerContent = Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFFFF9800),
          shape: BoxShape.circle,
        ),
      );
    } else if (day.isFuture) {
      // Future
      circleColor = Colors.transparent;
      borderColor = isDark ? Colors.white12 : const Color(0xFFE2E8F0);
      innerContent = const SizedBox();
    } else {
      // Past missed
      circleColor = isDark ? const Color(0xFF1E1E28) : const Color(0xFFF1F5F9);
      borderColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);
      innerContent = Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: isDark ? Colors.white24 : Colors.grey.shade400,
          shape: BoxShape.circle,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day.dayName,
          style: TextStyle(
            fontSize: 11,
            fontWeight: day.isToday ? FontWeight.bold : FontWeight.w500,
            color: day.isToday
                ? (isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100))
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: day.isToday ? 2 : 1.2,
            ),
            boxShadow: day.isPracticed
                ? [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(child: innerContent),
        ),
      ],
    );
  }
}

