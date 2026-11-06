import 'dart:math';
import '../../../data/models/math_problem.dart';
import '../../../data/models/app_settings.dart';
import 'safe_random.dart';

class RootPowerGenerator {
  final Random _rand = Random();

  MathProblem generateRoot(AppSettings settings, int radicandMax, int specialLimit, [bool isCampuran = false, bool allowAddSub = true, bool allowMulDiv = true]) {
    int maxRoot = specialLimit > 0 ? specialLimit : 20;
    int r = safeRandomInt(_rand, min(radicandMax, maxRoot)) + 1;
    int c1 = _rand.nextInt(maxRoot > 0 ? maxRoot : 1) + 1;
    int c2 = _rand.nextInt(maxRoot > 0 ? maxRoot : 1) + 1;
    int baseSq = r;
    int radicand = baseSq * baseSq;

    if (isCampuran || settings.difficulty == 'Hard' || settings.difficulty == 'Extreme') {
      List<int> ops = [];
      if (allowAddSub) {
        ops.add(0); // Add
        ops.add(2); // Sub
      }
      if (allowMulDiv) {
        ops.add(1); // Mul
      }
      if (ops.isEmpty) ops.addAll([0, 1, 2]);

      int op = ops[_rand.nextInt(ops.length)];
      if (op == 0) { // Add
        return MathProblem(questionText: '$c1√$radicand + $c2√$radicand', answer: '${(c1 + c2) * baseSq}');
      } else if (op == 1) { // Mul
        return MathProblem(questionText: '$c1√$radicand × $c2', answer: '${(c1 * baseSq) * c2}');
      } else { // Sub
        if (!settings.isNegativeNumbersEnabled && c1 < c2) {
          int temp = c1;
          c1 = c2;
          c2 = temp;
        }
        return MathProblem(questionText: '$c1√$radicand - $c2√$radicand', answer: '${(c1 - c2) * baseSq}');
      }
    }

    // Easy: Plain perfect square root (e.g. √25 = 5)
    if (settings.difficulty == 'Easy') {
      return MathProblem(questionText: '√$radicand', answer: '$r');
    }

    if (settings.difficulty == 'Medium') {
      // Medium: Coefficient with perfect square root (e.g. 3√25 = 15)
      return MathProblem(questionText: '$c1√$radicand', answer: '${c1 * baseSq}');
    }
    
    return MathProblem(questionText: '$c1√$radicand', answer: '${c1 * baseSq}');
  }

  MathProblem generatePower(AppSettings settings, int baseMax, int specialLimit, [bool isCampuran = false, bool allowAddSub = true, bool allowMulDiv = true]) {
    int expMax = specialLimit; 
    if (expMax < 2) expMax = 2;
    if (expMax > 5) expMax = 5;

    int b = safeRandomInt(_rand, baseMax) + 1;
    // Scale down base only if exponent is high to prevent overflow
    if (expMax >= 4 && b > 10) {
      b = _rand.nextInt(10) + 1;
    } else if (expMax >= 3 && b > 30) {
      b = _rand.nextInt(30) + 1;
    }
    
    if (settings.isNegativeNumbersEnabled && _rand.nextBool()) {
      b = -b;
    }

    int e = _rand.nextInt(expMax - 1) + 2;

    if (isCampuran || settings.difficulty == 'Extreme') {
      int b2 = _rand.nextInt(5) + 1;
      int e2 = _rand.nextInt(2) + 1;
      List<int> ops = [];
      if (allowMulDiv) ops.add(0); // Mul
      if (allowAddSub) ops.add(1); // Add
      if (ops.isEmpty) ops.addAll([0, 1]);

      int op = ops[_rand.nextInt(ops.length)];
      String bs = b < 0 ? '($b)' : '$b';
      if (op == 0) {
        return MathProblem(questionText: '$bs^$e × $b2^$e2', answer: '${pow(b, e) * pow(b2, e2)}');
      } else {
        return MathProblem(questionText: '$bs^$e + $b2^$e2', answer: '${pow(b, e) + pow(b2, e2)}');
      }
    }

    String bStr = b < 0 ? '($b)' : '$b';
    return MathProblem(questionText: '$bStr^$e', answer: '${pow(b, e).toInt()}');
  }

  MathProblem generateLogarithm(AppSettings settings, [bool isCampuran = false, bool allowAddSub = true, bool allowMulDiv = true]) {
    final bases = [2, 3, 5, 10];
    int base1 = bases[_rand.nextInt(bases.length)];
    int ans1 = base1 == 10 ? (_rand.nextInt(3) + 1) : (_rand.nextInt(3) + 2); // 2..4 or 1..3
    int val1 = pow(base1, ans1).toInt();

    if (isCampuran || settings.difficulty == 'Hard' || settings.difficulty == 'Extreme') {
      int base2 = bases[_rand.nextInt(bases.length)];
      int ans2 = base2 == 10 ? (_rand.nextInt(3) + 1) : (_rand.nextInt(3) + 1);
      int val2 = pow(base2, ans2).toInt();

      List<int> ops = [];
      if (allowAddSub) {
        ops.add(0); // Add
        ops.add(1); // Sub
      }
      if (allowMulDiv) {
        ops.add(2); // Mul
      }
      if (ops.isEmpty) ops.addAll([0, 1, 2]);

      int op = ops[_rand.nextInt(ops.length)];
      if (op == 0) {
        return MathProblem(
          questionText: 'log_$base1($val1) + log_$base2($val2)',
          answer: '${ans1 + ans2}',
        );
      } else if (op == 1) {
        if (!settings.isNegativeNumbersEnabled && ans1 < ans2) {
          int tempBase = base1; base1 = base2; base2 = tempBase;
          int tempVal = val1; val1 = val2; val2 = tempVal;
          int tempAns = ans1; ans1 = ans2; ans2 = tempAns;
        }
        return MathProblem(
          questionText: 'log_$base1($val1) - log_$base2($val2)',
          answer: '${ans1 - ans2}',
        );
      } else {
        return MathProblem(
          questionText: 'log_$base1($val1) × log_$base2($val2)',
          answer: '${ans1 * ans2}',
        );
      }
    }

    if (settings.difficulty == 'Medium') {
      int coeff = _rand.nextInt(3) + 2; // 2..4
      return MathProblem(
        questionText: '$coeff · log_$base1($val1)',
        answer: '${coeff * ans1}',
      );
    }

    return MathProblem(
      questionText: 'log_$base1($val1)',
      answer: '$ans1',
    );
  }
}

