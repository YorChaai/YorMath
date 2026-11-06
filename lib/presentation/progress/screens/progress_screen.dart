import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/history_provider.dart';
import '../../../core/providers/settings_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  static const int _startYear = 2024;
  static const int _endYear = 2030;
  static const int _totalYears = _endYear - _startYear + 1;

  late PageController _yearPageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentPage = (now.year - _startYear).clamp(0, _totalYears - 1);
    _yearPageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _yearPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final settingsProv = context.watch<SettingsProvider>();
    final lang = settingsProv.settings.language;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
        title: Text(
          lang == 'Indonesian' ? 'Progress Keseluruhan' : 'Overall Progress',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            _buildSummaryStats(historyProvider),
            const SizedBox(height: 32),
            Text(lang == 'Indonesian' ? 'Aktivitas Harian' : 'Daily Activity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildCalendarHeatmap(historyProvider),
            const SizedBox(height: 8),
            _buildLegend(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(HistoryProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            icon: Icons.sports_esports_rounded,
            label: 'Total Game',
            value: '${provider.totalGames}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            icon: Icons.calendar_today_rounded,
            label: 'Hari Aktif',
            value: '${provider.activeDays}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '${provider.currentStreak}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            icon: Icons.analytics_rounded,
            label: 'Rata-rata',
            value: '${provider.averageCorrect}',
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF565759),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00E5FF), size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeatmap(HistoryProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: Color(0xFF00E5FF)),
              onPressed: () {
                if (_currentPage > 0) {
                  _yearPageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                }
              },
            ),
            Text(
              '${_startYear + _currentPage}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF00E5FF),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF00E5FF)),
              onPressed: () {
                if (_currentPage < _totalYears - 1) {
                  _yearPageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _yearPageController,
            itemCount: _totalYears,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final year = _startYear + index;
              return _buildYearPage(year, provider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearPage(int year, HistoryProvider provider) {
    return Column(
      children: [
        _buildMonthRow(year, 1, 4, provider),
        const SizedBox(height: 16),
        _buildMonthRow(year, 5, 8, provider),
        const SizedBox(height: 16),
        _buildMonthRow(year, 9, 12, provider),
      ],
    );
  }

  Widget _buildMonthRow(int year, int startMonth, int endMonth, HistoryProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(endMonth - startMonth + 1, (index) {
        final month = startMonth + index;
        final daysInMonth = DateUtils.getDaysInMonth(year, month);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _monthLabel(month),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: ((daysInMonth / 7).ceil() * 14).toDouble(),
              height: 7 * 14.0,
              child: Wrap(
                direction: Axis.vertical,
                spacing: 2,
                runSpacing: 2,
                children: List.generate(daysInMonth, (dayIndex) {
                  final day = DateTime(year, month, dayIndex + 1);
                  final count = provider.dailyGameCounts[day] ?? 0;
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _heatColor(count),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }

  Color _heatColor(int count) {
    if (count == 0) return const Color(0xFFE0E0E0);
    if (count < 10) return const Color(0xFFA5D6A7);
    if (count < 20) return const Color(0xFF4CAF50);
    return const Color(0xFF1B5E20);
  }

  String _monthLabel(int month) {
    const labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return labels[month - 1];
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Sedikit ',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        _legendBox(const Color(0xFFE0E0E0)),
        _legendBox(const Color(0xFFA5D6A7)),
        _legendBox(const Color(0xFF4CAF50)),
        _legendBox(const Color(0xFF1B5E20)),
        const Text(
          ' Banyak',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
