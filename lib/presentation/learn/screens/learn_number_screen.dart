import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'learn_table_screen.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';

class LearnNumberScreen extends StatelessWidget {
  final List<String> operations;

  const LearnNumberScreen({super.key, required this.operations});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    final isTables = operations.contains('Perkalian') || operations.contains('Pembagian');
    String title = isTables
        ? AppLocalizations.get(lang, 'Multiplication Tables')
        : operations.map((op) => AppLocalizations.get(lang, op)).join(' & ');

    int startNumber = 1;
    int endNumber = 36;

    if (!isTables) {
      if (operations.contains('Pangkat') || operations.contains('Akar')) {
        startNumber = 2;
        endNumber = 20;
      } else if (operations.contains('Logaritma')) {
        startNumber = 2;
        endNumber = 10;
      } else if (operations.contains('Modulo')) {
        startNumber = 2;
        endNumber = 50;
      } else if (operations.contains('Pecahan')) {
        startNumber = 2;
        endNumber = 20;
      } else if (operations.contains('Perbandingan')) {
        startNumber = 1;
        endNumber = 20;
      }
    }

    int count = (endNumber - startNumber) + 1;
    const primaryColor = Color(0xFF0288D1);

    return Scaffold(
      backgroundColor: Colors.white,
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
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.1,
            ),
            itemCount: count,
            itemBuilder: (context, index) {
              int number = startNumber + index;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LearnTableScreen(operations: operations, baseNumber: number),
                    ),
                  );
                },
                child: Text(
                  number.toString(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
