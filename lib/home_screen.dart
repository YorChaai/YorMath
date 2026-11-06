import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'settings_screen.dart';
import 'presentation/learn/screens/learn_screen.dart';
import 'presentation/learn/screens/learn_number_screen.dart';
import 'presentation/custom_difficulty/screens/custom_difficulty_screen.dart';
import 'presentation/workout/screens/game_history_screen.dart';
import 'core/providers/settings_provider.dart';
import 'core/localization/app_localizations.dart';
import 'presentation/home/widgets/daily_streak_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAdvancedExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 240), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Primary Math Workout modes (matching reference app layout & order)
    final primaryModes = [
      {'title': 'Addition', 'key': 'Addition', 'op': 'Penjumlahan', 'type': 'history'},
      {'title': 'Subtraction', 'key': 'Subtraction', 'op': 'Pengurangan', 'type': 'history'},
      {'title': 'Multiplication', 'key': 'Multiplication', 'op': 'Perkalian', 'type': 'history'},
      {'title': 'Division', 'key': 'Division', 'op': 'Pembagian', 'type': 'history'},
      {'title': 'Customizable', 'key': 'Customizable', 'op': 'Customizable', 'type': 'custom'},
      {'title': 'Multiplication Tables', 'key': 'Multiplication Tables', 'op': 'Tables', 'type': 'tables'},
      {'title': 'Addition & Subtraction', 'key': 'Addition & Subtraction', 'op': 'Penjumlahan & Pengurangan', 'type': 'history'},
      {'title': 'Multiplication & Division', 'key': 'Multiplication & Division', 'op': 'Perkalian & Pembagian', 'type': 'history'},
      {'title': 'Mixed', 'key': 'Mixed', 'op': 'Aritmetika Campuran', 'type': 'history'},
      {'title': 'Arithmetic Memory', 'key': 'arithmetic_memory', 'op': 'Arithmetic Memory', 'type': 'history'},
    ];

    // Mathall Exclusive Advanced Features (Preserving 100% functionality)
    final advancedModes = [
      {'title': 'Pangkat', 'icon': Icons.superscript},
      {'title': 'Akar', 'icon': Icons.square_foot},
      {'title': 'Persentase', 'icon': Icons.percent},
      {'title': 'Faktorial', 'icon': Icons.priority_high},
      {'title': 'Nilai Mutlak', 'icon': Icons.straighten},
      {'title': 'Logaritma', 'icon': Icons.functions},
      {'title': 'Modulo', 'icon': Icons.pie_chart_outline},
      {'title': 'Custom Mixed', 'icon': Icons.shuffle},
    ];

    const primaryColor = Color(0xFF0288D1);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.get(lang, 'app_title'),
          style: TextStyle(
            color: isDark ? Colors.white : primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: isDark ? Colors.white : primaryColor, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    children: [
                      const DailyStreakCard(),
                      const SizedBox(height: 6),
                      // Primary Modes
                      ...primaryModes.map((item) {
                        final label = AppLocalizations.get(lang, item['key']!);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 1.5,
                              ),
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _handlePrimaryNav(context, item),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 12),

                      // Section for Advanced Mathall Operations
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Card(
                          elevation: 1,
                          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isDark ? Colors.white12 : Colors.blue.shade100,
                            ),
                          ),
                          child: ExpansionTile(
                            leading: const Icon(Icons.auto_awesome, color: primaryColor),
                            title: Text(
                              AppLocalizations.get(lang, 'advanced_operations'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : primaryColor,
                              ),
                            ),
                            initiallyExpanded: _isAdvancedExpanded,
                            onExpansionChanged: (val) {
                              setState(() => _isAdvancedExpanded = val);
                              if (val) {
                                _scrollToBottom();
                              }
                            },
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                        childAspectRatio: 3.3,
                                      ),
                                      itemCount: advancedModes.length,
                                      itemBuilder: (context, index) {
                                        final adv = advancedModes[index];
                                        final title = adv['title'] as String;
                                        final icon = adv['icon'] as IconData;
                                        return ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDark
                                                ? const Color(0xFF2A2A3C)
                                                : Colors.blue.shade50,
                                            foregroundColor: isDark ? Colors.white : primaryColor,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              side: BorderSide(color: Colors.blue.shade200),
                                            ),
                                          ),
                                          icon: Icon(icon, size: 18),
                                          label: Text(
                                            AppLocalizations.get(lang, title),
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => GameHistoryScreen(operation: title),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    // Mode Belajar Komprehensif
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: primaryColor,
                                          side: const BorderSide(color: primaryColor),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        icon: const Icon(Icons.menu_book, size: 18),
                                        label: Text(
                                          AppLocalizations.get(lang, 'learn_mode'),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const LearnScreen()),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Action Footer Bar (Heart Rating & Share, as in Math Workout)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite, color: primaryColor, size: 28),
                      tooltip: 'Rate App',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Terima kasih atas dukungan Anda! ⭐⭐⭐⭐⭐')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: primaryColor, size: 28),
                      tooltip: 'Share',
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text: 'Tingkatkan kecepatan berhitung dan latih ketajaman otakmu setiap hari bersama YorMath! 🧠⚡\n'
                                'Download dan coba latihan sekarang!',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePrimaryNav(BuildContext context, Map<String, String> item) {
    final type = item['type'];
    final op = item['op']!;

    if (type == 'custom') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomDifficultyScreen()),
      );
    } else if (type == 'tables') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LearnNumberScreen(operations: ['Perkalian', 'Pembagian']),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameHistoryScreen(operation: op)),
      );
    }
  }
}
