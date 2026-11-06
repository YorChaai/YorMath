import 'package:flutter/material.dart';

class AnswersScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    int correctCount = answerRecords.isNotEmpty
        ? answerRecords.where((r) => r.isCorrect == true).length
        : firstTryCorrectCount;
    int wrongCount = answerRecords.isNotEmpty
        ? answerRecords.where((r) => r.isCorrect == false).length
        : (totalQuestions - firstTryCorrectCount).clamp(0, totalQuestions);
    const primaryColor = Color(0xFF0288D1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
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
              const SizedBox(height: 24),
              const Text(
                'Answers',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Correct $correctCount',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF00BFA5),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Wrong $wrongCount',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Answers List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: answerRecords.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey.shade200,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final record = answerRecords[index];
                    final isCorrect = record.isCorrect;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: isCorrect ? const Color(0xFF00BFA5) : const Color(0xFFE53935),
                            size: 20,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${record.questionText} = ',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
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
                          const SizedBox(width: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Play Again Button (Fixed Footer)
              if (onPlayAgain != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
                      onPressed: onPlayAgain,
                      child: const Text(
                        'Play Again',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}
