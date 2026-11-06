import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/history_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/workout_result.dart';
import 'operation_setup_screen.dart';
import 'workout_screen.dart';
import '../../custom_mixed/screens/custom_mixed_screen.dart';
import '../../arithmetic_memory/screens/arithmetic_memory_screen.dart';
import '../../../presentation/custom_difficulty/widgets/preset_edit_dialog.dart';
import '../../../presentation/custom_difficulty/screens/custom_difficulty_screen.dart';

class GameHistoryScreen extends StatefulWidget {
  final String operation;

  const GameHistoryScreen({super.key, required this.operation});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  void _showSettingsDialog(BuildContext context, SettingsProvider provider) {
    final lang = provider.settings.language;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final currentDiff = provider.settings.difficulty;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                lang == 'English' ? 'Operation Settings' : 'Pengaturan Operasi',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Difficulty Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang == 'English' ? 'Difficulty:' : 'Tingkat Kesulitan:',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        DropdownButton<String>(
                          value: ['Easy', 'Medium', 'Hard', 'Challenging', 'Expert', 'Extreme', 'Custom'].contains(currentDiff)
                              ? currentDiff
                              : 'Medium',
                          underline: const SizedBox(),
                          items: ['Easy', 'Medium', 'Hard', 'Challenging', 'Expert', 'Extreme', 'Custom'].map((e) {
                            String display = AppLocalizations.get(lang, e.toLowerCase());
                            return DropdownMenuItem(value: e, child: Text(display));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              provider.setDifficulty(val);
                              setStateDialog(() {});
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    if (currentDiff == 'Custom') ...[
                      // 1-Variable Presets (Faktorial, Nilai Mutlak)
                      if (['Faktorial', 'Nilai Mutlak'].contains(widget.operation) ||
                          (widget.operation == 'Custom Mixed')) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'English' ? 'Preset (1 Variable):' : 'Preset (1 Variabel):',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomDifficultyScreen()));
                              },
                              child: Text(lang == 'English' ? 'Manage' : 'Kelola', style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: provider.settings.var1Presets.any((p) => p.id == provider.settings.activeVar1PresetId)
                                  ? provider.settings.activeVar1PresetId
                                  : (provider.settings.var1Presets.isNotEmpty ? provider.settings.var1Presets.first.id : null),
                              items: provider.settings.var1Presets.map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.name} (X: ${p.xDigit}d)', overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (id) {
                                if (id != null) {
                                  provider.setActiveVar1Preset(id);
                                  setStateDialog(() {});
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Digit X: ${provider.settings.activeVar1Preset.xDigit} digit', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 14),
                              label: Text(lang == 'English' ? 'Edit' : 'Ubah', style: const TextStyle(fontSize: 12)),
                              onPressed: () {
                                Navigator.pop(context);
                                showEditPresetDialog(context, provider, provider.settings.activeVar1Preset, 1);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      // 2-Variable Presets (Penjumlahan, Pengurangan, Perkalian, Pembagian, dll)
                      if (['Penjumlahan', 'Pengurangan', 'Perkalian', 'Pembagian', 'Penjumlahan & Pengurangan', 'Perkalian & Pembagian', 'Persentase', 'Modulo', 'Perbandingan', 'Desimal', 'Aritmetika Campuran', 'Custom Mixed'].contains(widget.operation)) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'English' ? 'Preset (2 Variables):' : 'Preset (2 Variabel):',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomDifficultyScreen()));
                              },
                              child: Text(lang == 'English' ? 'Manage' : 'Kelola', style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: provider.settings.var2Presets.any((p) => p.id == provider.settings.activeVar2PresetId)
                                  ? provider.settings.activeVar2PresetId
                                  : (provider.settings.var2Presets.isNotEmpty ? provider.settings.var2Presets.first.id : null),
                              items: provider.settings.var2Presets.map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.name} (X:${p.xDigit}d, Y:${p.yDigit ?? p.xDigit}d${p.isSwappable ? ", SW" : ""})', overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (id) {
                                if (id != null) {
                                  provider.setActiveVar2Preset(id);
                                  setStateDialog(() {});
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('X=${provider.settings.activeVar2Preset.xDigit}d, Y=${provider.settings.activeVar2Preset.yDigit ?? 1}d${provider.settings.activeVar2Preset.isSwappable ? " (Swappable)" : ""}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 14),
                              label: Text(lang == 'English' ? 'Edit' : 'Ubah', style: const TextStyle(fontSize: 12)),
                              onPressed: () {
                                Navigator.pop(context);
                                showEditPresetDialog(context, provider, provider.settings.activeVar2Preset, 2);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Complex Numbers Presets (Akar, Pangkat, Logaritma)
                      if (['Akar', 'Pangkat', 'Logaritma', 'Campuran Lain-lain', 'Custom Mixed'].contains(widget.operation)) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'English' ? 'Preset (Complex Numbers):' : 'Preset (Akar/Pangkat/Log):',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomDifficultyScreen()));
                              },
                              child: Text(lang == 'English' ? 'Manage' : 'Kelola', style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: provider.settings.otherPresets.any((p) => p.id == provider.settings.activeOtherPresetId)
                                  ? provider.settings.activeOtherPresetId
                                  : (provider.settings.otherPresets.isNotEmpty ? provider.settings.otherPresets.first.id : null),
                              items: provider.settings.otherPresets.map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.name} (Pkt: ${p.pangkatLimit}, Akr: ${p.akarLimit})', overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (id) {
                                if (id != null) {
                                  provider.setActiveOtherPreset(id);
                                  setStateDialog(() {});
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Pangkat: Max ${provider.settings.activeOtherPreset.pangkatLimit}, Akar: Max ${provider.settings.activeOtherPreset.akarLimit}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 14),
                              label: Text(lang == 'English' ? 'Edit' : 'Ubah', style: const TextStyle(fontSize: 12)),
                              onPressed: () {
                                Navigator.pop(context);
                                showEditPresetDialog(context, provider, provider.settings.activeOtherPreset, 3);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Arithmetic Memory Presets
                      if (widget.operation == 'Arithmetic Memory' || widget.operation == 'Operasi Berantai') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'English' ? 'Preset (Arithmetic Memory):' : 'Preset (Operasi Berantai):',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomDifficultyScreen()));
                              },
                              child: Text(lang == 'English' ? 'Manage' : 'Kelola', style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: provider.settings.memoryPresets.any((p) => p.id == provider.settings.activeMemoryPresetId)
                                  ? provider.settings.activeMemoryPresetId
                                  : (provider.settings.memoryPresets.isNotEmpty ? provider.settings.memoryPresets.first.id : null),
                              items: provider.settings.memoryPresets.map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name, overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (id) {
                                if (id != null) {
                                  provider.setActiveMemoryPreset(id);
                                  setStateDialog(() {});
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Basis: ${provider.settings.activeMemoryPreset.baseDigit}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 14),
                              label: Text(lang == 'English' ? 'Edit' : 'Ubah', style: const TextStyle(fontSize: 12)),
                              onPressed: () {
                                Navigator.pop(context);
                                showEditPresetDialog(context, provider, provider.settings.activeMemoryPreset, 4);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      const Divider(),
                    ],
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        lang == 'English' ? "Negative Numbers" : "Bilangan Negatif",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(lang == 'English' ? "Allow negative answers" : "Izinkan hasil negatif"),
                      value: provider.settings.isNegativeNumbersEnabled,
                      onChanged: (val) {
                        provider.toggleNegativeNumbers(val);
                        setStateDialog(() {});
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(lang == 'English' ? 'Close' : 'Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final settingsProv = context.watch<SettingsProvider>();
    final lang = settingsProv.settings.language;
    final isDurationMode = settingsProv.settings.isDurationMode;
    final difficulty = settingsProv.settings.difficulty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chartColor = isDark ? const Color(0xFF26A69A) : const Color(0xFF1976D2);

    final isMemoryOp = widget.operation == 'Arithmetic Memory' || widget.operation == 'Operasi Berantai';
    final int memSteps = difficulty == 'Medium'
        ? 10
        : (difficulty == 'Hard' ? 20 : (difficulty == 'Extreme' ? 40 : 5));
    final limitValue = isMemoryOp
        ? memSteps
        : (isDurationMode ? settingsProv.settings.durationMinutes : settingsProv.settings.questionCount);
    final queryOp = isMemoryOp ? 'Arithmetic Memory' : widget.operation;

    final history = historyProvider.getHistoryForConfig(
      queryOp,
      isMemoryOp ? false : isDurationMode,
      limitValue,
      difficulty,
    );
    final top5 = historyProvider.getTop5ForConfig(
      queryOp,
      isMemoryOp ? false : isDurationMode,
      limitValue,
      difficulty,
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
          AppLocalizations.get(lang, widget.operation),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context, settingsProv);
            },
          ),
        ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Icon(
                                isMemoryOp
                                    ? Icons.linear_scale
                                    : (isDurationMode ? Icons.timer_outlined : Icons.format_list_numbered),
                                color: const Color(0xFF1976D2),
                                size: 22,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$limitValue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                isMemoryOp
                                    ? (lang == 'English' ? 'Steps' : 'Langkah')
                                    : (isDurationMode
                                        ? AppLocalizations.get(lang, "duration_minutes")
                                        : AppLocalizations.get(lang, "questions")),
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
                                AppLocalizations.get(lang, difficulty.toLowerCase()),
                                style: TextStyle(
                                  fontSize: 15,
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
                      ],
                    ),
                  ),
                ),
                if (difficulty == 'Custom') ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => _showSettingsDialog(context, settingsProv),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE1F5FE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF0288D1).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tune, color: Color(0xFF0288D1), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getCustomPresetSummary(settingsProv, widget.operation),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF01579B),
                                  ),
                                ),
                                Text(
                                  lang == 'English' ? 'Tap to change preset or settings' : 'Ketuk untuk ganti preset atau setelan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF0288D1), size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Chart Section Card
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
                              lang == 'Indonesian' ? 'Grafik Perkembangan' : 'Progress Chart',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (history.length > 1) ...[
                          Builder(builder: (context) {
                            final scores = history.map((e) => e.score.toDouble()).toList();
                            final maxScore = scores.reduce((a, b) => a > b ? a : b);
                            final minScore = scores.reduce((a, b) => a < b ? a : b);
                            final chartMaxY = maxScore == 0
                                ? (isMemoryOp ? 1.0 : 10.0)
                                : (maxScore == minScore ? maxScore + (isMemoryOp ? 1.0 : 5.0) : maxScore * 1.15);
                            final chartInterval = isMemoryOp
                                ? 1.0
                                : ((chartMaxY / 5) > 0 ? (chartMaxY / 5) : 1.0);
                            final bool canCurve = history.length > 2 && maxScore != minScore;

                            return SizedBox(
                              height: 200,
                              child: LineChart(
                                LineChartData(
                                  minY: 0,
                                  maxY: chartMaxY,
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
                                        reservedSize: isMemoryOp ? 38 : (isDurationMode ? 36 : 56),
                                        interval: chartInterval,
                                        getTitlesWidget: (value, meta) {
                                          if (value < 0) return const SizedBox.shrink();
                                          final textStyle = TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                          );
                                          if (isMemoryOp) {
                                            if (value.toInt() == 1) {
                                              return Text(lang == 'English' ? 'Pass' : 'Lulus', style: textStyle);
                                            }
                                            if (value.toInt() == 0) {
                                              return Text(lang == 'English' ? 'Fail' : 'Gagal', style: textStyle);
                                            }
                                            return const SizedBox.shrink();
                                          } else if (isDurationMode) {
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
                                      isCurved: canCurve,
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
                            );
                          }),
                        ] else
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
                                    _formatScore(r, lang),
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
                                    _formatScore(r, lang),
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

                // Start button
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
                      if (widget.operation == "Custom Mixed" || widget.operation == "Campuran Kustom") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CustomMixedScreen()),
                        );
                        return;
                      }

                      if (widget.operation == "Arithmetic Memory" || widget.operation == "Operasi Berantai") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ArithmeticMemoryScreen()),
                        );
                        return;
                      }

                      final requiresSetup = widget.operation == "Penjumlahan" ||
                          widget.operation == "Pengurangan" ||
                          widget.operation == "Perkalian" ||
                          widget.operation == "Pembagian" ||
                          widget.operation == "Penjumlahan & Pengurangan" ||
                          widget.operation == "Perkalian & Pembagian" ||
                          widget.operation == "Aritmetika Campuran";

                      if (requiresSetup) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OperationSetupScreen(
                              operation: widget.operation,
                              initialNegativeNumbersEnabled: settingsProv.settings.isNegativeNumbersEnabled,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutScreen(
                              operation: widget.operation,
                              overrideNegativeNumbers: settingsProv.settings.isNegativeNumbersEnabled,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      AppLocalizations.get(lang, 'start'),
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

  String _formatScore(WorkoutResult r, String lang) {
    if (r.operation == 'Arithmetic Memory' || r.operation == 'Operasi Berantai') {
      return r.score == 1
          ? (lang == 'English' ? 'Pass' : 'Lulus')
          : (lang == 'English' ? 'Fail' : 'Gagal');
    }
    return r.isDurationMode ? r.score.toString() : _formatTime(r.score);
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds < 0) return '00:00';
    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _getCustomPresetSummary(SettingsProvider provider, String op) {
    if (['Faktorial', 'Nilai Mutlak'].contains(op)) {
      final p = provider.settings.activeVar1Preset;
      return 'Preset Aktif: ${p.name} (X: ${p.xDigit} Digit)';
    } else if (['Akar', 'Pangkat', 'Logaritma'].contains(op)) {
      final p = provider.settings.activeOtherPreset;
      return 'Preset Aktif: ${p.name} (Pangkat: Max ${p.pangkatLimit}, Akar: Max ${p.akarLimit})';
    } else if (op == 'Arithmetic Memory' || op == 'Operasi Berantai') {
      final p = provider.settings.activeMemoryPreset;
      return 'Preset Aktif: ${p.name} (Angka Awal: ${p.baseDigit})';
    } else {
      final p = provider.settings.activeVar2Preset;
      String sw = p.isSwappable ? ', SW' : '';
      return 'Preset Aktif: ${p.name} (X: ${p.xDigit}d, Y: ${p.yDigit ?? p.xDigit}d$sw)';
    }
  }
}
