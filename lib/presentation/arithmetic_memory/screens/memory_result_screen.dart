import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/memory_generator.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';

class MemoryResultScreen extends StatelessWidget {
  final bool isCorrect;
  final int userAnswer;
  final int startNumber;
  final List<MemoryStep> sequence;
  final String difficulty;

  const MemoryResultScreen({
    super.key,
    required this.isCorrect,
    required this.userAnswer,
    required this.startNumber,
    required this.sequence,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    int correctAnswer = sequence.last.runningTotal;
    final lang = context.watch<SettingsProvider>().settings.language;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(lang, 'result')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              size: 100,
              color: isCorrect ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isCorrect 
                ? (lang == 'Indonesian' ? 'Ingatan Hebat!' : 'Awesome Memory!') 
                : (lang == 'Indonesian' ? 'Hampir Saja!' : 'Oops, close!'),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.get(lang, "difficulty")}: ${AppLocalizations.get(lang, difficulty.toLowerCase())}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Answers Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(lang == 'Indonesian' ? 'Jawaban Anda' : 'Your Answer', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          '$userAnswer',
                          style: TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 60, color: Colors.grey.shade300),
                    Column(
                      children: [
                        Text(lang == 'Indonesian' ? 'Jawaban Benar' : 'Correct Answer', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          '$correctAnswer',
                          style: const TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            Text(
              lang == 'Indonesian' ? 'Rincian Urutan' : 'Sequence Breakdown',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
                // Sequence List
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sequence.length + 1,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      leading: const CircleAvatar(child: Text('0')),
                      title: Text(AppLocalizations.get(lang, 'initial_number'), style: const TextStyle(color: Colors.grey)),
                      trailing: Text('$startNumber', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    );
                  }
                  
                  final step = sequence[index - 1];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Text('$index'),
                    ),
                    title: Text(
                      step.displayOperation,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      '= ${step.runningTotal}',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text(AppLocalizations.get(lang, 'back_to_home'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
