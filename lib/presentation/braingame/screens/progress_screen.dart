// progress screen — calendar heatmap + riwayat permainan
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/game_history.dart';
import '../services/history_storage.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<DateTime, int> _dailyCounts = {};
  List<GameHistoryEntry> _allEntries = [];
  List<GameHistoryEntry> _selectedDayEntries = [];
  DateTime? _selectedDate;
  bool _loading = true;

  // fixed range 2024–2030
  static const int _startYear = 2024;
  static const int _endYear = 2030;
  static const int _totalYears = _endYear - _startYear + 1;

  // controller untuk scroll ke tahun sekarang
  late PageController _yearPageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // hitung index tahun sekarang (2026 = index 2)
    final now = DateTime.now();
    _currentPage = (now.year - _startYear).clamp(0, _totalYears - 1);
    _yearPageController = PageController(initialPage: _currentPage);
    _loadData();
  }

  @override
  void dispose() {
    _yearPageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final counts = await HistoryStorage.getDailyGameCounts();
    final all = await HistoryStorage.loadAll();
    setState(() {
      _dailyCounts = counts;
      _allEntries = all;
      _loading = false;
    });
  }

  void _selectDate(DateTime date) async {
    final entries = await HistoryStorage.getEntriesForDate(date);
    setState(() {
      _selectedDate = date;
      _selectedDayEntries = entries;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<SettingsProvider>().settings.language;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.get(lang, 'progress'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // summary stats
                      _buildSummaryStats(isDark, lang),

                      const SizedBox(height: 24),

                      // calendar heatmap
                      Text(
                        AppLocalizations.get(lang, 'daily_activity'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCalendarHeatmap(isDark),

                      const SizedBox(height: 8),
                      _buildLegend(isDark, lang),

                      const SizedBox(height: 24),

                      // selected day detail
                      if (_selectedDate != null) _buildSelectedDayDetail(isDark, lang),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryStats(bool isDark, String lang) {
    final totalGames = _allEntries.length;
    final totalDays = _dailyCounts.length;
    final avgAccuracy = totalGames > 0
        ? (_allEntries.fold<double>(0, (sum, e) => sum + e.overallAccuracy) /
                  totalGames *
                  100)
              .round()
        : 0;

    // hitung streak
    int streak = 0;
    DateTime checkDay = DateTime.now();
    checkDay = DateTime(checkDay.year, checkDay.month, checkDay.day);
    while (_dailyCounts.containsKey(checkDay)) {
      streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            icon: Icons.sports_esports_rounded,
            label: AppLocalizations.get(lang, 'total_games'),
            value: '$totalGames',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            icon: Icons.calendar_today_rounded,
            label: AppLocalizations.get(lang, 'active_days'),
            value: '$totalDays',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            icon: Icons.local_fire_department_rounded,
            label: AppLocalizations.get(lang, 'streak'),
            value: '$streak',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            icon: Icons.analytics_rounded,
            label: AppLocalizations.get(lang, 'average'),
            value: '$avgAccuracy%',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1976D2), size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeatmap(bool isDark) {
    final currentYear = _startYear + _currentPage;
    return Column(
      children: [
        // year navigator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF1976D2),
              ),
              onPressed: _currentPage > 0
                  ? () {
                      _yearPageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  : null,
            ),
            Text(
              '$currentYear',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF1976D2),
              ),
              onPressed: _currentPage < _totalYears - 1
                  ? () {
                      _yearPageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // page view untuk tahun — 3 baris x 4 bulan
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
              return _buildYearPage(year, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearPage(int year, bool isDark) {
    return Column(
      children: [
        _buildMonthRow(year, 1, 4, isDark),
        const SizedBox(height: 16),
        _buildMonthRow(year, 5, 8, isDark),
        const SizedBox(height: 16),
        _buildMonthRow(year, 9, 12, isDark),
      ],
    );
  }

  Widget _buildMonthRow(int year, int startMonth, int endMonth, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(endMonth - startMonth + 1, (index) {
        final month = startMonth + index;
        final daysInMonth = DateUtils.getDaysInMonth(year, month);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // nama bulan
            Text(
              _monthLabel(month),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            // grid hari — vertical wrap (7 baris per kolom = hari per minggu)
            SizedBox(
              width: ((daysInMonth / 7).ceil() * 14).toDouble(),
              height: 7 * 14.0,
              child: Wrap(
                direction: Axis.vertical,
                spacing: 2,
                runSpacing: 2,
                children: List.generate(daysInMonth, (dayIndex) {
                  final day = DateTime(year, month, dayIndex + 1);
                  final count = _dailyCounts[day] ?? 0;
                  final isSelected =
                      _selectedDate != null &&
                      _selectedDate!.year == day.year &&
                      _selectedDate!.month == day.month &&
                      _selectedDate!.day == day.day;
                  return GestureDetector(
                    onTap: () => _selectDate(day),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _heatColor(count, isDark),
                        borderRadius: BorderRadius.circular(2),
                        border: isSelected
                            ? Border.all(color: const Color(0xFF1976D2), width: 1.5)
                            : null,
                      ),
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

  Color _heatColor(int count, bool isDark) {
    if (count == 0) return isDark ? Colors.white12 : Colors.grey.shade300;
    if (count <= 1) return const Color(0xFF81C784); // hijau muda
    if (count <= 3) return const Color(0xFF388E3C); // hijau
    return const Color(0xFF1B5E20); // hijau tua
  }

  String _monthLabel(int month) {
    const labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return labels[month - 1];
  }

  Widget _buildLegend(bool isDark, String lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${AppLocalizations.get(lang, 'few')} ',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        _legendBox(isDark ? Colors.white12 : Colors.grey.shade300),
        _legendBox(const Color(0xFF81C784)),
        _legendBox(const Color(0xFF388E3C)),
        _legendBox(const Color(0xFF1B5E20)),
        Text(
          ' ${AppLocalizations.get(lang, 'many')}',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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

  Widget _buildSelectedDayDetail(bool isDark, String lang) {
    final dateStr =
        '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppLocalizations.get(lang, 'history_for_date')} $dateStr',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedDayEntries.isEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  AppLocalizations.get(lang, 'no_games_today'),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          ...List.generate(_selectedDayEntries.length, (index) {
            final entry = _selectedDayEntries[index];
            return _buildHistoryCard(entry, index + 1, isDark);
          }),
      ],
    );
  }

  Widget _buildHistoryCard(GameHistoryEntry entry, int number, bool isDark) {
    final overallPct = (entry.overallAccuracy * 100).round();
    final posPct = (entry.positionAccuracy * 100).round();
    final sndPct = (entry.soundAccuracy * 100).round();
    final time =
        '${entry.playedAt.hour.toString().padLeft(2, '0')}:${entry.playedAt.minute.toString().padLeft(2, '0')}';
    final durationMin = entry.durationSeconds ~/ 60;
    final durationSec = entry.durationSeconds % 60;
    final durationStr = durationMin > 0
        ? '${durationMin}m ${durationSec}s'
        : '${durationSec}s';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // game number badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _scoreColor(overallPct).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '#$number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _scoreColor(overallPct),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.nLevel}-Back',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '$time • $durationStr\n${entry.totalTrials} trials • ${entry.totalErrors} errors',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // overall accuracy
                Column(
                  children: [
                    Text(
                      '$overallPct%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _scoreColor(overallPct),
                      ),
                    ),
                    Text(
                      'Akurasi',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade200),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat('Posisi', '$posPct%', const Color(0xFF1976D2), isDark),
                _miniStat('Suara', '$sndPct%', const Color(0xFF2E7D32), isDark),
                _miniStat('Wins', '${entry.wins}', Colors.amber.shade800, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _scoreColor(int pct) {
    if (pct >= 80) return const Color(0xFF2E7D32);
    if (pct >= 50) return Colors.amber.shade800;
    return const Color(0xFFD32F2F);
  }
}
