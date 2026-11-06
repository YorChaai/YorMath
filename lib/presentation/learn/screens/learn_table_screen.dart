import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/learn_config.dart';
import '../../workout/screens/workout_screen.dart';
import '../../../core/providers/mastery_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';

class LearnTableScreen extends StatefulWidget {
  final List<String> operations;
  final int baseNumber;

  const LearnTableScreen({
    super.key,
    required this.operations,
    required this.baseNumber,
  });

  @override
  State<LearnTableScreen> createState() => _LearnTableScreenState();
}

class _LearnTableScreenState extends State<LearnTableScreen> {
  int _currentOpIndex = 0;
  final List<LearnRange> _selectedRanges = [LearnRange(1, 10)];
  bool _showChartLines = false;
  final NegativeMode _negativeMode = NegativeMode.off;

  static const primaryColor = Color(0xFF0288D1);

  @override
  Widget build(BuildContext context) {
    final mastery = context.watch<MasteryProvider>();
    final settingsProv = context.watch<SettingsProvider>();
    final lang = settingsProv.settings.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String currentOp = widget.operations.isNotEmpty
        ? widget.operations[_currentOpIndex]
        : 'Perkalian';

    String title = currentOp == 'Pembagian'
        ? (lang == 'English' ? 'Division Tables' : 'Tabel Pembagian')
        : (lang == 'English' ? 'Multiplication Tables' : 'Tabel Perkalian');

    // Generate list of all active numbers based on selected ranges
    List<int> activeNumbers = [];
    _selectedRanges.sort((a, b) => a.start.compareTo(b.start));
    for (var r in _selectedRanges) {
      for (int i = r.start; i <= r.end; i++) {
        activeNumbers.add(i);
      }
    }

    if (activeNumbers.isEmpty) {
      for (int i = 1; i <= 10; i++) {
        activeNumbers.add(i);
      }
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Stack(
            children: [
              Column(
                children: [
                  // List of Equations
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      itemCount: activeNumbers.length,
                      itemBuilder: (context, index) {
                        int base = widget.baseNumber;
                        int rangeVal = activeNumbers[index];

                        if (_negativeMode == NegativeMode.x || _negativeMode == NegativeMode.xy) {
                          base = -base;
                        }
                        if (_negativeMode == NegativeMode.y || _negativeMode == NegativeMode.xy) {
                          rangeVal = -rangeVal;
                        }

                        String equation = '';
                        if (currentOp == 'Perkalian') {
                          equation = '$base  ×  $rangeVal  =  ${base * rangeVal}';
                        } else if (currentOp == 'Pembagian') {
                          if (base == 0) base = 1;
                          int product = base * rangeVal;
                          equation = '$product  ÷  $base  =  $rangeVal';
                        } else {
                          equation = '$base + $rangeVal = ${base + rangeVal}';
                        }

                        // Mastery score
                        int score = mastery.getScore(currentOp, widget.baseNumber, activeNumbers[index]);
                        Color barColor = const Color(0xFFB3E5FC);
                        if (score >= 4) {
                          barColor = Colors.greenAccent.shade700;
                        } else if (score >= 2) {
                          barColor = Colors.orangeAccent;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              // Light blue status bar on the left (as in Math Workout)
                              Container(
                                width: 36,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _showChartLines ? barColor : const Color(0xFFB3E5FC),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Text(
                                  equation,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Range Tabs [1-10], [11-20], [21-30], [31-40], [41-50]
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildRangePill(1, 10),
                          _buildRangePill(11, 20),
                          _buildRangePill(21, 30),
                          _buildRangePill(31, 40),
                          _buildRangePill(41, 50),
                        ],
                      ),
                    ),
                  ),

                  // Practice Button (Math Workout Style)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          final config = LearnConfig(
                            baseNumber: widget.baseNumber,
                            activeRanges: _selectedRanges.isEmpty ? [LearnRange(1, 10)] : _selectedRanges,
                            operation: currentOp,
                            negativeMode: _negativeMode,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutScreen(
                                operation: currentOp,
                                learnConfig: config,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.get(lang, 'practice'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Side Floating Action Buttons (Left: Bar Chart, Right: Switcher × / ÷)
              Positioned(
                left: 16,
                bottom: 140,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => setState(() => _showChartLines = !_showChartLines),
                    child: Icon(_showChartLines ? Icons.bar_chart : Icons.bar_chart_outlined, size: 26),
                  ),
                ),
              ),

              if (widget.operations.length > 1)
                Positioned(
                  right: 16,
                  bottom: 140,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentOpIndex = (_currentOpIndex + 1) % widget.operations.length;
                        });
                      },
                      child: Text(
                        currentOp == 'Perkalian' ? '÷' : '×',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangePill(int start, int end) {
    bool isSelected = _selectedRanges.any((r) => r.start == start && r.end == end);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _selectedRanges.clear();
            _selectedRanges.add(LearnRange(start, end));
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : const Color(0xFFE1F5FE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$start-$end',
            style: TextStyle(
              color: isSelected ? Colors.white : primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
