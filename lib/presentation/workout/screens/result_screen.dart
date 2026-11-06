import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/history_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../data/models/workout_result.dart';
import 'workout_screen.dart';
import 'answers_screen.dart';
import '../../../core/localization/app_localizations.dart';

class ResultScreen extends StatefulWidget {
  final WorkoutResult result;
  final List<dynamic>? answerRecords;
  final int? firstTryCorrectCount;

  const ResultScreen({super.key, required this.result, this.answerRecords, this.firstTryCorrectCount});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final settingsProv = context.watch<SettingsProvider>();
    final lang = settingsProv.settings.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chartColor = isDark ? const Color(0xFF26A69A) : const Color(0xFF1976D2);

    final history = historyProvider.getHistoryForConfig(
      widget.result.operation,
      widget.result.isDurationMode,
      widget.result.limitValue,
      widget.result.difficulty,
    );
    final top5 = historyProvider.getTop5ForConfig(
      widget.result.operation,
      widget.result.isDurationMode,
      widget.result.limitValue,
      widget.result.difficulty,
    );
    final last5 = history.take(5).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFF0288D1),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.get(lang, widget.result.operation),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Config summary card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Icon(widget.result.isDurationMode ? Icons.timer_outlined : Icons.format_list_numbered, color: const Color(0xFF1976D2), size: 22),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.result.limitValue}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                widget.result.isDurationMode
                                    ? AppLocalizations.get(lang, "duration_minutes")
                                    : AppLocalizations.get(lang, "questions"),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(height: 36, width: 1, color: isDark ? Colors.white12 : Colors.grey.shade300),
                        Expanded(
                          child: Column(
                            children: [
                              const Icon(Icons.speed, color: Color(0xFF2E7D32), size: 22),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.get(lang, widget.result.difficulty.toLowerCase()),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                AppLocalizations.get(lang, "difficulty"),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(height: 36, width: 1, color: isDark ? Colors.white12 : Colors.grey.shade300),
                        Expanded(
                          child: Column(
                            children: [
                              const Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 22),
                              const SizedBox(height: 4),
                              Text(
                                widget.result.isDurationMode
                                    ? '${widget.result.score}'
                                    : _formatTime(widget.result.score),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.result.isDurationMode
                                    ? AppLocalizations.get(lang, "score")
                                    : AppLocalizations.get(lang, "time"),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Chart Card
                Card(
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
                            Icon(Icons.show_chart_rounded, color: chartColor, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.get(lang, "tables"),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (history.length > 1)
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                                    strokeWidth: 1,
                                  ),
                                  getDrawingVerticalLine: (value) => FlLine(
                                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 42,
                                      getTitlesWidget: (value, meta) {
                                        final textStyle = TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                        );
                                        if (widget.result.isDurationMode) {
                                          return Text(value.toInt().toString(), style: textStyle);
                                        } else {
                                          return Text(_formatTime(value.toInt()), style: textStyle);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: history.reversed.toList().asMap().entries.map((e) {
                                      return FlSpot(e.key.toDouble(), e.value.score.toDouble());
                                    }).toList(),
                                    isCurved: true,
                                    color: chartColor,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                        radius: 4,
                                        color: chartColor,
                                        strokeWidth: 2,
                                        strokeColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                                      ),
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: chartColor.withValues(alpha: isDark ? 0.25 : 0.12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 140,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bar_chart_rounded, size: 36, color: isDark ? Colors.white24 : Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  lang == 'Indonesian'
                                      ? 'Mainkan lebih banyak untuk melihat grafik!'
                                      : 'Play more to see your history chart!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Top 5 High Scores Card
                Card(
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
                            const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              lang == 'Indonesian' ? '5 Skor Tertinggi' : 'Top 5 High Scores',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (top5.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              lang == 'Indonesian' ? 'Belum ada riwayat' : 'No history yet',
                              style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontSize: 13),
                            ),
                          )
                        else
                          ...top5.asMap().entries.map((entry) {
                            final idx = entry.key + 1;
                            final r = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '#$idx',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: idx == 1 ? Colors.amber : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                    ),
                                  ),
                                  Text(
                                    r.isDurationMode ? r.score.toString() : _formatTime(r.score),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Last 5 Results Card
                Card(
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
                            const Icon(Icons.history_rounded, color: Color(0xFF1976D2), size: 22),
                            const SizedBox(width: 8),
                            Text(
                              lang == 'Indonesian' ? '5 Hasil Terakhir' : 'The last 5 results',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (last5.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              lang == 'Indonesian' ? 'Belum ada riwayat' : 'No history yet',
                              style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontSize: 13),
                            ),
                          )
                        else
                          ...last5.asMap().entries.map((entry) {
                            final idx = entry.key + 1;
                            final r = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '#$idx',
                                    style: TextStyle(
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    r.isDurationMode ? r.score.toString() : _formatTime(r.score),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (widget.answerRecords != null && widget.firstTryCorrectCount != null) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? const Color(0xFF80D8FF) : const Color(0xFF0288D1),
                        side: BorderSide(color: isDark ? const Color(0xFF80D8FF) : const Color(0xFF0288D1), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnswersScreen(
                              answerRecords: widget.answerRecords!,
                              firstTryCorrectCount: widget.firstTryCorrectCount!,
                              totalQuestions: widget.result.isDurationMode ? widget.result.score : widget.result.limitValue,
                              onPlayAgain: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => WorkoutScreen(operation: widget.result.operation)),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Text(
                        '${lang == 'Indonesian' ? 'Lihat Jawaban' : 'Review Answers'} (${widget.firstTryCorrectCount}/${widget.result.isDurationMode ? widget.result.score : widget.result.limitValue})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Play Again / Start button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0288D1),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => WorkoutScreen(operation: widget.result.operation)),
                      );
                    },
                    child: Text(
                      AppLocalizations.get(lang, "play_again"),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.00';
  }
}
