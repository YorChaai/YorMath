import 'package:flutter/material.dart';
import '../../../../data/models/math_problem.dart';
import 'workout_screen.dart';

enum AnswerFilterType { all, wrong, correct }

class AnswersScreen extends StatefulWidget {
  final List<dynamic> answerRecords;
  final int firstTryCorrectCount;
  final int totalQuestions;
  final VoidCallback? onPlayAgain;

  const AnswersScreen({
    super.key,
    required this.answerRecords,
    required this.firstTryCorrectCount,
    required this.totalQuestions,
    this.onPlayAgain,
  });

  @override
  State<AnswersScreen> createState() => _AnswersScreenState();
}

class _AnswersScreenState extends State<AnswersScreen> {
  AnswerFilterType _selectedFilter = AnswerFilterType.all;

  @override
  Widget build(BuildContext context) {
    int correctCount = widget.answerRecords.isNotEmpty
        ? widget.answerRecords.where((r) => r.isCorrect == true).length
        : widget.firstTryCorrectCount;
    int wrongCount = widget.answerRecords.isNotEmpty
        ? widget.answerRecords.where((r) => r.isCorrect == false).length
        : (widget.totalQuestions - widget.firstTryCorrectCount).clamp(0, widget.totalQuestions);
    const primaryColor = Color(0xFF0288D1);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredRecords = widget.answerRecords.where((r) {
      if (_selectedFilter == AnswerFilterType.wrong) {
        return r.isCorrect == false;
      } else if (_selectedFilter == AnswerFilterType.correct) {
        return r.isCorrect == true;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Answers',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Summary Counts
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Color(0xFF00BFA5)),
                        const SizedBox(width: 6),
                        Text(
                          'Benar: $correctCount',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF00BFA5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel, size: 16, color: Color(0xFFE53935)),
                        const SizedBox(width: 6),
                        Text(
                          'Salah: $wrongCount',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Filter Segment Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Semua (${widget.answerRecords.length})',
                      type: AnswerFilterType.all,
                      isDark: isDark,
                      activeColor: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Salah ($wrongCount)',
                      type: AnswerFilterType.wrong,
                      isDark: isDark,
                      activeColor: const Color(0xFFE53935),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Benar ($correctCount)',
                      type: AnswerFilterType.correct,
                      isDark: isDark,
                      activeColor: const Color(0xFF00BFA5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Answers List
              Expanded(
                child: filteredRecords.isEmpty
                    ? Center(
                        child: Text(
                          _selectedFilter == AnswerFilterType.wrong
                              ? 'Hebat! Tidak ada soal yang salah 🎉'
                              : 'Tidak ada data jawaban',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: filteredRecords.length,
                        separatorBuilder: (context, index) => Divider(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final record = filteredRecords[index];
                          final isCorrect = record.isCorrect;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? const Color(0xFF00BFA5).withValues(alpha: 0.15)
                                        : const Color(0xFFE53935).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCorrect ? Icons.check : Icons.close,
                                    color: isCorrect ? const Color(0xFF00BFA5) : const Color(0xFFE53935),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        '${record.questionText} = ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      if (isCorrect)
                                        Text(
                                          record.correctAnswer,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00BFA5),
                                          ),
                                        )
                                      else ...[
                                        Text(
                                          record.userAnswer,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE53935),
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          record.correctAnswer,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00BFA5),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    if (wrongCount > 0) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.replay_rounded, size: 20),
                          label: Text(
                            'Latih Ulang Soal Salah ($wrongCount)',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            final retryProblems = widget.answerRecords
                                .where((r) => r.isCorrect == false)
                                .map((r) => MathProblem(
                                      questionText: r.questionText,
                                      answer: r.correctAnswer,
                                    ))
                                .toList();

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkoutScreen(
                                  operation: 'Perbaikan Soal Salah',
                                  customProblems: retryProblems,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    if (widget.onPlayAgain != null)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor, width: 1.5),
                            foregroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: widget.onPlayAgain,
                          child: const Text(
                            'Play Again',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required AnswerFilterType type,
    required bool isDark,
    required Color activeColor,
  }) {
    final isSelected = _selectedFilter == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = type),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.white12 : Colors.grey.shade300),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
