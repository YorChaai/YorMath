import 'dart:math';
import '../../../data/models/math_problem.dart';
import '../../../data/models/app_settings.dart';

class _Operand {
  final String text;
  final double value;

  _Operand(this.text, this.value);
}

class BasicGenerator {
  final Random _rand = Random();

  int _safeRandomInt(int maxVal) {
    if (maxVal <= 0) return 0;
    if (maxVal <= 4294967296) {
      return _rand.nextInt(maxVal);
    } else {
      return (_rand.nextDouble() * maxVal).floor();
    }
  }

  String _formatAnswer(double ans) {
    // If it's a clean integer, format without decimals
    if (ans == ans.toInt()) {
      return ans.toInt().toString();
    }
    // Otherwise limit to 2 decimal places to keep it playable
    String s = ans.toStringAsFixed(2);
    if (s.endsWith('.00')) {
      return s.substring(0, s.length - 3);
    } else if (s.endsWith('0')) {
      return s.substring(0, s.length - 1);
    }
    return s;
  }

  _Operand _generateOperand(List<String> activeTypes, int minVal, int maxVal, bool isNegativeEnabled, bool isFirstOperand, String operation, int? threshold, int decimalPlaces) {
    String type = 'Bulat';
    if (activeTypes.isNotEmpty) {
      type = activeTypes[_rand.nextInt(activeTypes.length)];
    }

    int effectiveMax = maxVal;
    if (threshold != null) {
      bool isComplexOp = operation == 'Perkalian' || operation == 'Pembagian';
      bool isComplexType = ['Desimal', 'Persentase', 'Akar', 'Kuadrat', 'Pecahan'].contains(type);
      if (isComplexOp || isComplexType) {
        effectiveMax = min(maxVal, threshold);
        if (effectiveMax < minVal) effectiveMax = minVal;
      }
    }

    int x = minVal + _safeRandomInt(effectiveMax - minVal + 1);
    if (isNegativeEnabled && _rand.nextInt(100) < 30) x = -x;
    if (x == 0 && type == 'Pembagian') x = 1; // Basic safety

    String formatOpt(String txt, bool isFirst) {
      if (isFirst) {
        return txt;
      }
      return txt.startsWith('-') ? '($txt)' : txt;
    }

    if (type == 'Desimal') {
      bool isMultiplicationOrDivision = operation == 'Perkalian' || operation == 'Pembagian';
      if (isMultiplicationOrDivision && _rand.nextInt(100) < 20) {
        x = 0;
      }

      double val = x.toDouble();
      if (decimalPlaces > 0) {
        int denominator = pow(10, decimalPlaces).toInt();
        int fractionPart = _rand.nextInt(denominator);
        if (x == 0 && fractionPart == 0) {
          fractionPart = 1;
        }
        val = x + (fractionPart / denominator);
      }
      String s = val.toStringAsFixed(decimalPlaces);
      if (s.contains('.')) {
        while (s.endsWith('0')) {
          s = s.substring(0, s.length - 1);
        }
        if (s.endsWith('.')) {
          s = s.substring(0, s.length - 1);
        }
      }
      return _Operand(formatOpt(s, isFirstOperand), double.parse(s));
    } else if (type == 'Persentase') {
      int pMax = effectiveMax > 0 ? effectiveMax : 99;
      int p = _rand.nextInt(pMax) + 1;
      if (isNegativeEnabled && _rand.nextInt(100) < 30) {
        p = -p;
      }
      return _Operand(formatOpt('$p%', isFirstOperand), p / 100.0);
    } else if (type == 'Kuadrat') {
      int base = x;
      if (effectiveMax > 20) {
        base = _rand.nextInt(15) + 1;
        if (x < 0) base = -base;
      }
      return _Operand(formatOpt('$base²', isFirstOperand), (base * base).toDouble());
    } else if (type == 'Akar') {
      int root = x;
      if (effectiveMax > 100) {
        root = _rand.nextInt(50) + 1;
        if (x < 0) root = -root;
      }
      int radicand = root * root;
      return _Operand(formatOpt('√$radicand', isFirstOperand), root.toDouble());
    } else if (type == 'Pecahan') {
      int numMax = effectiveMax;
      int denomMax = effectiveMax;
      if (denomMax < 2) denomMax = 5;
      
      int d = _safeRandomInt(denomMax > 1 ? denomMax - 1 : 1) + 2;
      int n = _safeRandomInt(numMax) + 1;
      if (x < 0) n = -n; // inherit negative from x
      
      int g = n.gcd(d).abs();
      n = n ~/ g;
      d = d ~/ g;
      if (d == 1) {
        d = 2; // enforce fraction look
        if (n.abs().gcd(d) > 1) {
          n = n < 0 ? -1 : 1;
        }
      }
      
      return _Operand(formatOpt('$n/$d', isFirstOperand), n / d);
    }
    
    // Bulat
    return _Operand(formatOpt('$x', isFirstOperand), x.toDouble());
  }

  MathProblem generate(String operation, AppSettings settings, int min1, int max1, int min2, int max2, {int? threshold, int? decimalPlaces}) {
    // Check if this operation uses the new mixed types
    bool isMixedSupported = ['Penjumlahan', 'Pengurangan', 'Perkalian', 'Pembagian'].contains(operation);
    List<String> types = isMixedSupported ? settings.activeNumberTypes : ['Bulat'];

    int effectiveThreshold = threshold ?? 505;
    int effectiveDecimalPrec = decimalPlaces ?? 1;

    if (isMixedSupported) {
      _Operand op1 = _generateOperand(types, min1, max1, settings.isNegativeNumbersEnabled, true, operation, effectiveThreshold, effectiveDecimalPrec);
      _Operand op2 = _generateOperand(types, min2, max2, settings.isNegativeNumbersEnabled, false, operation, effectiveThreshold, effectiveDecimalPrec);

      switch (operation) {
        case 'Penjumlahan':
          return MathProblem(questionText: '${op1.text} + ${op2.text}', answer: _formatAnswer(op1.value + op2.value));
        case 'Pengurangan':
          // If no negative allowed, prevent negative answer
          if (!settings.isNegativeNumbersEnabled && op1.value < op2.value) {
            _Operand temp = op1;
            op1 = op2;
            op2 = temp;
          }
          return MathProblem(questionText: '${op1.text} - ${op2.text}', answer: _formatAnswer(op1.value - op2.value));
        case 'Perkalian':
          return MathProblem(questionText: '${op1.text} × ${op2.text}', answer: _formatAnswer(op1.value * op2.value));
        case 'Pembagian':
          if (types.length == 1 && types.contains('Bulat')) {
            int divisor = op2.value.toInt();
            if (divisor == 0) divisor = 1;
            int ansInt = op1.value.toInt();
            if (ansInt == 0) ansInt = 1;
            if (!settings.isNegativeNumbersEnabled) {
              divisor = divisor.abs();
              ansInt = ansInt.abs();
            }
            int dividend = divisor * ansInt;
            String divText = dividend < 0 ? '($dividend)' : '$dividend';
            String divisorText = divisor < 0 ? '($divisor)' : '$divisor';
            return MathProblem(
              questionText: '$divText ÷ $divisorText',
              answer: '$ansInt',
            );
          } else {
            if (op2.value == 0) {
               op2 = _Operand('1', 1.0);
            }
            return MathProblem(questionText: '${op1.text} ÷ ${op2.text}', answer: _formatAnswer(op1.value / op2.value));
          }
      }
    }

    // Original fallback for other operations
    int x = min1 + _safeRandomInt(max1 - min1 + 1);
    int y = min2 + _safeRandomInt(max2 - min2 + 1);

    if (settings.isNegativeNumbersEnabled) {
      if (_rand.nextInt(100) < 30) x = -x;
      if (_rand.nextInt(100) < 40) y = -y;
    }

    switch (operation) {
      case 'Perbandingan':
        return MathProblem(questionText: '$x : $y = ${x * 2} : ?', answer: '${y * 2}');
      case 'Persentase':
        final commonPercents = [5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 75, 80, 90];
        int p1 = commonPercents[_rand.nextInt(commonPercents.length)];
        int mult1 = (p1 % 10 == 0) ? 10 : (p1 % 5 == 0 ? 20 : 100);
        int n1 = (_rand.nextInt(10) + 1) * mult1;
        if (n1 <= 0) n1 = 100;
        double ans1 = (p1 * n1) / 100.0;

        if (settings.difficulty == 'Hard' || settings.difficulty == 'Extreme') {
          int p2 = commonPercents[_rand.nextInt(commonPercents.length)];
          int mult2 = (p2 % 10 == 0) ? 10 : (p2 % 5 == 0 ? 20 : 100);
          int n2 = (_rand.nextInt(10) + 1) * mult2;
          if (n2 <= 0) n2 = 50;
          double ans2 = (p2 * n2) / 100.0;

          int op = _rand.nextInt(2); // 0: Add, 1: Sub
          if (op == 0) {
            double total = ans1 + ans2;
            String ansStr = total == total.toInt() ? '${total.toInt()}' : _formatAnswer(total);
            return MathProblem(
              questionText: '$p1% × $n1 + $p2% × $n2',
              answer: ansStr,
            );
          } else {
            if (!settings.isNegativeNumbersEnabled && ans1 < ans2) {
              int tempP = p1; p1 = p2; p2 = tempP;
              int tempN = n1; n1 = n2; n2 = tempN;
              double tempAns = ans1; ans1 = ans2; ans2 = tempAns;
            }
            double total = ans1 - ans2;
            String ansStr = total == total.toInt() ? '${total.toInt()}' : _formatAnswer(total);
            return MathProblem(
              questionText: '$p1% × $n1 - $p2% × $n2',
              answer: ansStr,
            );
          }
        }

        String ansStr = ans1 == ans1.toInt() ? '${ans1.toInt()}' : _formatAnswer(ans1);
        return MathProblem(
          questionText: '$p1% × $n1',
          answer: ansStr,
        );
      case 'Faktorial':
        int maxN = min(max1, 7);
        if (maxN < 1) maxN = 5;
        int minN = min(min1, maxN);
        if (minN < 1) minN = 1;
        int n = minN + _safeRandomInt(maxN - minN + 1);
        int fact = 1;
        for (int i = 1; i <= n; i++) {
          fact *= i;
        }
        return MathProblem(questionText: '$n!', answer: '$fact');
      case 'Nilai Mutlak':
        int val = min1 + _safeRandomInt(max1 - min1 + 1);
        int neg = -val;
        return MathProblem(questionText: '|$neg|', answer: '${neg.abs()}');
      case 'Logaritma':
        List<int> bases = [2, 3, 4, 5, 10];
        int base = bases[_rand.nextInt(bases.length)];
        int ans = _rand.nextInt(4) + 1;
        int value = pow(base, ans).toInt();
        return MathProblem(questionText: 'log_$base($value)', answer: '$ans');
      case 'Modulo':
        int b = min2 + _safeRandomInt(max(2, max2 - min2 + 1));
        if (b <= 1) b = 2;
        int a = min1 + _safeRandomInt(max(10, max1 - min1 + 1));
        return MathProblem(questionText: '$a mod $b', answer: '${a % b}');
      default:
        return MathProblem(questionText: '$x + $y', answer: '${x + y}');
    }
  }
}
