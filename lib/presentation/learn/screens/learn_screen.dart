import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'learn_number_screen.dart';
import 'learn_table_screen.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(lang, 'learn_mode')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.get(lang, 'select_category'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildCategoryButton(
                context,
                AppLocalizations.get(lang, 'Penjumlahan & Pengurangan'),
                Icons.add_circle_outline,
                ['Penjumlahan', 'Pengurangan'],
              ),
              const SizedBox(height: 16),
              _buildCategoryButton(
                context,
                AppLocalizations.get(lang, 'Perkalian & Pembagian'),
                Icons.close,
                ['Perkalian', 'Pembagian'],
              ),
              const SizedBox(height: 16),
              _buildCategoryButton(
                context,
                AppLocalizations.get(lang, 'Pangkat & Akar'),
                Icons.superscript,
                ['Pangkat', 'Akar'],
              ),
              const SizedBox(height: 16),
              _buildCategoryButton(
                context,
                AppLocalizations.get(lang, 'Logaritma & Modulo'),
                Icons.functions,
                ['Logaritma', 'Modulo'],
              ),
              const SizedBox(height: 16),
              _buildCategoryButton(
                context,
                AppLocalizations.get(lang, 'Pecahan, Persen, Perbandingan'),
                Icons.pie_chart_outline,
                ['Pecahan', 'Persentase', 'Perbandingan'],
              ),
              const SizedBox(height: 16),
              _buildDirectButton(
                context,
                AppLocalizations.get(lang, 'Faktorial'),
                Icons.priority_high,
                'Faktorial',
              ),
              const SizedBox(height: 16),
              _buildDirectButton(
                context,
                AppLocalizations.get(lang, 'Nilai Mutlak'),
                Icons.vertical_align_center,
                'Nilai Mutlak',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String title, IconData icon, List<String> operations) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon, size: 28),
        label: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LearnNumberScreen(operations: operations),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDirectButton(BuildContext context, String title, IconData icon, String opName) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon, size: 28),
        label: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LearnTableScreen(operations: [opName], baseNumber: 1),
            ),
          );
        },
      ),
    );
  }
}
