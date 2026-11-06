import 'dart:math';
import '../../../data/models/math_problem.dart';
import '../../../data/models/app_settings.dart';

class DecimalGenerator {
  final Random _rand = Random();

  int _safeRandomInt(int maxVal) {
    if (maxVal <= 0) return 0;
    if (maxVal <= 4294967296) {
      return _rand.nextInt(maxVal);
    } else {
      return (_rand.nextDouble() * maxVal).floor();
    }
  }

  MathProblem generate(AppSettings settings, int intMax, int precision) {
    // Determine precision based on setting or difficulty
    int p = precision > 0 ? precision : 1;
    if (settings.difficulty == 'Hard') p = 2;
    if (settings.difficulty == 'Extreme') p = 3;

    // Randomize precision up to 'p' for each number
    int p1 = _rand.nextInt(p + 1);
    int p2 = _rand.nextInt(p + 1);

    // Ensure at least one of them is a decimal, otherwise it's just integer math
    if (p1 == 0 && p2 == 0) {
      if (_rand.nextBool()) {
        p1 = _rand.nextInt(p) + 1;
      } else {
        p2 = _rand.nextInt(p) + 1;
      }
    }

    double factor1 = pow(10, p1).toDouble();
    double factor2 = pow(10, p2).toDouble();

    double n1 = (_safeRandomInt(intMax * factor1.toInt()) + 1) / factor1;
    double n2 = (_safeRandomInt(intMax * factor2.toInt()) + 1) / factor2;

    if (settings.isNegativeNumbersEnabled) {
      if (_rand.nextBool()) n1 = -n1;
      if (_rand.nextBool()) n2 = -n2;
    }

    List<String> ops = ['+'];
    if (settings.difficulty != 'Easy') ops.add('-');
    if (settings.difficulty == 'Hard' || settings.difficulty == 'Extreme' || settings.difficulty == 'Custom') {
      ops.add('*');
    }

    String op = ops[_rand.nextInt(ops.length)];

    if (op == '-' && !settings.isNegativeNumbersEnabled && n1 < n2) {
      double temp = n1;
      n1 = n2;
      n2 = temp;
    }

    String formatNum(double val) {
      if (val == val.toInt()) return val.toInt().toString();
      return val.toString();
    }

    String s1 = formatNum(n1);
    String s2 = formatNum(n2);
    String f1 = n1 < 0 ? '($s1)' : s1;
    String f2 = n2 < 0 ? '($s2)' : s2;

    String opSymbol = op == '*' ? '×' : op;
    String qText = '$f1 $opSymbol $f2';
    double result = 0;

    switch (op) {
      case '+': result = n1 + n2; break;
      case '-': result = n1 - n2; break;
      case '*': result = n1 * n2; break;
    }

    // Fix floating point issues
    result = double.parse(result.toStringAsFixed(p * 2));
    String answer = result == result.toInt() ? result.toInt().toString() : result.toString();

    return MathProblem(questionText: qText, answer: answer);
  }
}
