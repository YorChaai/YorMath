import 'dart:math';
import '../../data/models/app_settings.dart';
import 'generators/safe_random.dart';

class MemoryStep {
  final String displayOperation; // e.g. "+ 3", "× 2", "÷ 4"
  final int value;               // The operand value
  final int runningTotal;        // The correct total after this step

  MemoryStep({
    required this.displayOperation,
    required this.value,
    required this.runningTotal,
  });
}

class ArithmeticMemoryGenerator {
  final Random _rand = Random();

  bool _isPerfectSquare(int n) {
    if (n < 0) return false;
    int root = sqrt(n).round();
    return root * root == n;
  }

  bool _isPerfectCube(int n) {
    int absN = n.abs();
    int root = pow(absN, 1.0 / 3.0).round();
    return (n < 0 ? -root : root) * (n < 0 ? -root : root) * (n < 0 ? -root : root) == n;
  }

  int _factorial(int n) {
    if (n <= 1) return 1;
    return n * _factorial(n - 1);
  }

  int? _getLogBase(int n) {
    if (n <= 1) return null;
    for (int base = 2; base <= 10; base++) {
      int temp = n;
      while (temp % base == 0) {
        temp ~/= base;
      }
      if (temp == 1) return base;
    }
    return null;
  }

  String _formatExponent(int e) {
    switch (e) {
      case 2: return '²';
      case 3: return '³';
      case 4: return '⁴';
      case 5: return '⁵';
      default: return '^$e';
    }
  }

  /// Generates a sequence of steps for Arithmetic Memory
  List<MemoryStep> generateSequence(int startNumber, int steps, AppSettings settings) {
    List<MemoryStep> sequence = [];
    int currentTotal = startNumber;
    
    int min1 = 1;
    int max1 = 9;
    int maxMultDiv = max1;
    bool allowAkar = false;
    bool allowPangkat = false;
    bool allowPecahan = false;
    bool allowDesimal = false;
    bool allowPersentase = false;
    bool allowFaktorial = false;
    bool allowMutlak = false;
    bool allowLogaritma = false;
    bool allowModulo = false;
    bool? customAllowNegative;
    
    if (settings.difficulty == 'Custom') {
      final preset = settings.memoryPresets.firstWhere(
        (p) => p.id == settings.activeMemoryPresetId,
        orElse: () => CustomPreset(id: '', name: '', xDigit: 1),
      );
      max1 = pow(10, preset.xDigit).toInt() - 1;
      maxMultDiv = preset.maxThreshold ?? 505;
      min1 = 1;
      allowAkar = preset.allowAkar;
      allowPangkat = preset.allowPangkat;
      allowPecahan = preset.allowPecahan;
      allowDesimal = preset.allowDesimal;
      allowPersentase = preset.allowPersentase;
      allowFaktorial = preset.allowFaktorial;
      allowMutlak = preset.allowMutlak;
      allowLogaritma = preset.allowLogaritma;
      allowModulo = preset.allowModulo;
      customAllowNegative = preset.allowNegative;
    } else {
      int digits = 1;
      if (settings.difficulty == 'Medium') {
        digits = 2;
      }
      if (settings.difficulty == 'Hard') {
        digits = 3;
      }
      if (settings.difficulty == 'Extreme') {
        digits = 3;
      }
      max1 = pow(10, digits).toInt() - 1;
      maxMultDiv = max1;
      min1 = digits == 1 ? 1 : pow(10, digits - 1).toInt();
      
      // Use activeNumberTypes for standard difficulties!
      allowDesimal = settings.activeNumberTypes.contains("Desimal");
      allowPersentase = settings.activeNumberTypes.contains("Persentase");
      allowAkar = settings.activeNumberTypes.contains("Akar");
      allowPangkat = settings.activeNumberTypes.contains("Kuadrat");
      allowPecahan = settings.activeNumberTypes.contains("Pecahan");
    }
    bool allowNegative = customAllowNegative ?? settings.isNegativeNumbersEnabled;
    
    for (int i = 0; i < steps; i++) {
      int operand = 0;
      String displayOp = '';

      List<int> availableOps = [0, 1, 2, 3];
      
      if (allowAkar) {
        if (_isPerfectSquare(currentTotal) && currentTotal > 1) availableOps.add(4); // Akar total
        if (_isPerfectCube(currentTotal) && currentTotal.abs() > 1) availableOps.add(9); // Akar pangkat 3
        availableOps.add(5); // + - Akar
      }
      if (allowPangkat) {
        availableOps.add(6); // + - Pangkat
        if (currentTotal.abs() <= 30 && currentTotal.abs() > 1) availableOps.add(10); // Pangkat pada total
      }
      if (allowDesimal) {
        if (currentTotal % 2 == 0) availableOps.add(7); // Perkalian desimal
        availableOps.add(11); // Pembagian desimal
      }
      if (allowPecahan) {
        availableOps.add(8); // Perkalian / Pembagian Pecahan
        availableOps.add(12); // Pecahan kompleks
      }
      if (allowPersentase) {
        availableOps.add(13); // Persentase
      }
      if (allowFaktorial && currentTotal >= 0 && currentTotal <= 6) {
        availableOps.add(14); // Faktorial
      }
      if (allowMutlak && currentTotal < 0) {
        availableOps.add(15); // Mutlak
      }
      if (allowLogaritma) {
        if (_getLogBase(currentTotal) != null) {
          availableOps.add(16); // Logaritma
        }
      }
      if (allowModulo && currentTotal > 0) {
        availableOps.add(17); // Modulo
      }

      int opType = availableOps[_rand.nextInt(availableOps.length)];

      switch (opType) {
        case 0: // +
          operand = min1 + safeRandomInt(_rand, max1 - min1 + 1);
          if (allowNegative && _rand.nextBool()) operand = -operand;
          currentTotal += operand;
          String opStr = operand < 0 ? '($operand)' : '$operand';
          displayOp = '+ $opStr';
          break;
        case 1: // -
          if (!allowNegative && currentTotal <= 1) {
            operand = min1 + safeRandomInt(_rand, max1 - min1 + 1);
            currentTotal += operand;
            displayOp = '+ $operand';
            break;
          }
          operand = min1 + safeRandomInt(_rand, max1 - min1 + 1);
          if (!allowNegative && currentTotal - operand < 0) {
            operand = safeRandomInt(_rand, max(1, currentTotal)) + 1;
            if (operand > currentTotal) operand = currentTotal;
          }
          if (allowNegative && _rand.nextBool()) operand = -operand;
          currentTotal -= operand;
          displayOp = operand < 0 ? '- ($operand)' : '- $operand';
          break;
        case 2: // x
          int operandMax = min(max1, maxMultDiv);
          operand = min1 + safeRandomInt(_rand, operandMax - min1 + 1);
          if (allowNegative && _rand.nextBool()) operand = -operand;
          currentTotal *= operand;
          String opStr = operand < 0 ? '($operand)' : '$operand';
          displayOp = '× $opStr';
          break;
        case 3: // ÷
          List<int> factors = _getFactors(currentTotal.abs());
          int operandMax = min(max1, maxMultDiv);
          List<int> validFactors = factors.where((f) => f >= min1 && f <= operandMax).toList();
          
          if (validFactors.isEmpty || currentTotal == 0) {
            operand = min1 + safeRandomInt(_rand, max1 - min1 + 1);
            if (allowNegative && _rand.nextBool()) operand = -operand;
            currentTotal += operand;
            displayOp = operand < 0 ? '+ ($operand)' : '+ $operand';
          } else {
            operand = validFactors[_rand.nextInt(validFactors.length)];
            if (allowNegative && _rand.nextBool()) operand = -operand;
            currentTotal ~/= operand;
            displayOp = operand < 0 ? '÷ ($operand)' : '÷ $operand';
          }
          break;
          
        case 4: // Akar total
          int root = sqrt(currentTotal).toInt();
          displayOp = '√$currentTotal';
          currentTotal = root;
          break;
          
        case 5: // Tambah/Kurang Akar (+ √169)
          int r = _rand.nextInt(max1 > 30 ? 30 : max1) + 1; // Limit root so it doesn't get ridiculously large
          int sq = r * r;
          bool isAdd = _rand.nextBool();
          if (!isAdd && !allowNegative && currentTotal - r < 0) {
            isAdd = true;
          }
          if (isAdd) {
            displayOp = '+ √$sq';
          } else {
            displayOp = '- √$sq';
          }
          currentTotal += isAdd ? r : -r;
          break;

        case 6: // Tambah/Kurang Pangkat (- 4²)
          int base = _rand.nextInt(10) + 2; // 2 to 11
          int exp = _rand.nextInt(3) + 2; // 2, 3, 4
          int val = pow(base, exp).toInt();
          bool isAdd = _rand.nextBool();
          if (!isAdd && !allowNegative && currentTotal - val < 0) {
            isAdd = true;
          }
          if (isAdd) {
            displayOp = '+ $base${_formatExponent(exp)}';
          } else {
            displayOp = '- $base${_formatExponent(exp)}';
          }
          currentTotal += isAdd ? val : -val;
          break;
          
        case 7: // Perkalian desimal
          double val = 0.5;
          List<double> validDecimals = [];
          
          if (currentTotal != 0) {
            if (currentTotal % 10 == 0) {
              for (int i = 1; i <= 29; i++) {
                if (i % 10 != 0) validDecimals.add(i / 10.0);
              }
            } else if (currentTotal % 5 == 0) {
              for (int i = 1; i <= 14; i++) {
                if (i % 5 != 0) validDecimals.add((i * 2) / 10.0);
              }
            } else if (currentTotal % 4 == 0) {
              validDecimals.addAll([0.25, 0.75, 1.25, 1.75, 2.25]);
            } else if (currentTotal % 2 == 0) {
              validDecimals.addAll([0.5, 1.5, 2.5]);
            }
          }
          
          if (validDecimals.isNotEmpty) {
            val = validDecimals[_rand.nextInt(validDecimals.length)];
          } else {
            // Jika angka saat ini ganjil atau tidak bisa dikali desimal menjadi bulat, 
            // fallback ke perkalian bulat tapi berkedok desimal (.0) jika mau, atau ubah val jadi bulat
            val = (_rand.nextInt(3) + 1).toDouble(); 
          }
          
          String formatNum(double v) {
            if (v == v.toInt()) return v.toInt().toString();
            return v.toString();
          }
          
          String decStr = formatNum(val).replaceAll('.', ',');
          displayOp = '× $decStr';
          currentTotal = (currentTotal * val).round();
          break;
          
        case 8: // Pecahan (÷ 1/6 atau × 1/4)
          bool doDiv = _rand.nextBool();
          if (doDiv) {
            int denom = _rand.nextInt(9) + 2; // 2 to 10
            displayOp = '÷ 1/$denom';
            currentTotal *= denom;
          } else {
            List<int> factors = _getFactors(currentTotal.abs());
            List<int> valid = factors.where((f) => f >= 2 && f <= 10).toList();
            if (valid.isNotEmpty) {
              int denom = valid[_rand.nextInt(valid.length)];
              displayOp = '× 1/$denom';
              currentTotal ~/= denom;
            } else {
              int denom = _rand.nextInt(9) + 2;
              displayOp = '÷ 1/$denom';
              currentTotal *= denom;
            }
          }
          break;
          
        case 9: // Akar pangkat 3 total
          int absN = currentTotal.abs();
          int root = pow(absN, 1.0 / 3.0).round();
          if (currentTotal < 0) root = -root;
          displayOp = '³√$currentTotal';
          currentTotal = root;
          break;
          
        case 10: // Pangkat pada Total
          int exp = 2;
          if (currentTotal.abs() <= 10 && _rand.nextBool()) {
            exp = 3;
          }
          if (currentTotal.abs() <= 5 && _rand.nextBool()) {
            exp = 4;
          }
          if (exp == 2) {
            displayOp = '²';
          } else if (exp == 3) {
            displayOp = '³';
          } else if (exp == 4) {
            displayOp = '⁴';
          } else {
            displayOp = '^$exp';
          }
          currentTotal = pow(currentTotal, exp).toInt();
          break;
          
        case 11: // Pembagian desimal
          List<double> divs = [0.1, 0.2, 0.5, 0.25, 0.05, 0.01];
          double val = divs[_rand.nextInt(divs.length)];
          String decStr = val.toString().replaceAll('.', ',');
          if (val == 0.1) {
            decStr = "0,1";
          } else if (val == 0.2) {
            decStr = "0,2";
          } else if (val == 0.5) {
            decStr = "0,5";
          } else if (val == 0.25) {
            decStr = "0,25";
          } else if (val == 0.05) {
            decStr = "0,05";
          } else if (val == 0.01) {
            decStr = "0,01";
          }
          displayOp = '÷ $decStr';
          currentTotal = (currentTotal / val).round();
          break;
          
        case 12: // Pecahan kompleks
          bool doDiv = _rand.nextBool();
          if (doDiv) {
            int x = _rand.nextInt(9) + 2;
            int y = _rand.nextInt(9) + 2;
            while (x == y) {
              y = _rand.nextInt(9) + 2;
            }
            List<int> factors = _getFactors(currentTotal.abs());
            if (factors.contains(x) || currentTotal % x == 0) {
              displayOp = '÷ $x/$y';
              currentTotal = (currentTotal ~/ x) * y;
            } else {
              displayOp = '× $y';
              currentTotal *= y;
            }
          } else {
            int x = _rand.nextInt(9) + 2;
            int y = _rand.nextInt(9) + 2;
            while (x == y) {
              y = _rand.nextInt(9) + 2;
            }
            List<int> factors = _getFactors(currentTotal.abs());
            if (factors.contains(y) || currentTotal % y == 0) {
              displayOp = '× $x/$y';
              currentTotal = (currentTotal ~/ y) * x;
            } else {
              displayOp = '× $x';
              currentTotal *= x;
            }
          }
          break;
          
        case 13: // Persentase
          bool doDiv = _rand.nextBool();
          if (doDiv) {
            List<int> validP = [];
            for (int i = 1; i <= 5000; i++) {
              if ((currentTotal.abs() * 100) % i == 0) {
                validP.add(i);
              }
            }
            int p;
            List<int> niceP = validP.where((e) => [10, 20, 25, 50, 75, 100].contains(e)).toList();
            if (niceP.isNotEmpty && _rand.nextBool()) {
              p = niceP[_rand.nextInt(niceP.length)];
            } else if (validP.isNotEmpty) {
              p = validP[_rand.nextInt(validP.length)];
            } else {
              p = 50; // Fallback
            }
            displayOp = '÷ $p%';
            currentTotal = (currentTotal * 100) ~/ p;
          } else {
            List<int> validP = [];
            for (int i = 1; i <= 5000; i++) {
              if ((currentTotal.abs() * i) % 100 == 0) {
                validP.add(i);
              }
            }
            int p;
            List<int> niceP = validP.where((e) => [10, 20, 25, 50, 75, 100].contains(e)).toList();
            if (niceP.isNotEmpty && _rand.nextBool()) {
              p = niceP[_rand.nextInt(niceP.length)];
            } else if (validP.isNotEmpty) {
              p = validP[_rand.nextInt(validP.length)];
            } else {
              p = 100; // Fallback
            }
            displayOp = '× $p%';
            currentTotal = (currentTotal * p) ~/ 100;
          }
          break;
          
        case 14: // Faktorial
          currentTotal = _factorial(currentTotal);
          displayOp = '!';
          break;
          
        case 15: // Mutlak
          currentTotal = currentTotal.abs();
          displayOp = '|x|';
          break;
          
        case 16: // Logaritma
          int base = _getLogBase(currentTotal) ?? 2;
          int result = 0;
          int temp = currentTotal;
          while (temp > 1) {
            temp ~/= base;
            result++;
          }
          currentTotal = result;
          displayOp = 'log$base';
          break;
          
        case 17: // Modulo
          int modMax = max(2, max1);
          operand = _rand.nextInt(modMax > 2 ? modMax - 1 : 1) + 2; // avoid mod 1
          currentTotal = currentTotal % operand;
          displayOp = 'mod $operand';
          break;
      }

      sequence.add(MemoryStep(
        displayOperation: displayOp,
        value: operand,
        runningTotal: currentTotal,
      ));
    }

    return sequence;
  }

  List<int> _getFactors(int n) {
    if (n <= 1) return [];
    List<int> factors = [];
    for (int i = 2; i <= n; i++) {
      if (n % i == 0) {
        factors.add(i);
      }
    }
    return factors;
  }
}
