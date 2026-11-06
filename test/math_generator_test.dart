import 'package:flutter_test/flutter_test.dart';
import 'package:mathall/core/utils/math_generator.dart';
import 'package:mathall/data/models/app_settings.dart';

void main() {
  group('MathGenerator Parity and Regressions Tests', () {
    final generator = MathGenerator();
    final defaultSettings = AppSettings();

    test('Penjumlahan & Pengurangan generates valid problems with + and -', () {
      bool foundAddition = false;
      bool foundSubtraction = false;

      for (int i = 0; i < 50; i++) {
        final problem = generator.generate('Penjumlahan & Pengurangan', defaultSettings);
        expect(problem.questionText.isNotEmpty, isTrue);
        expect(problem.answer.isNotEmpty, isTrue);
        if (problem.questionText.contains('+')) foundAddition = true;
        if (problem.questionText.contains('-')) foundSubtraction = true;
      }

      expect(foundAddition, isTrue);
      expect(foundSubtraction, isTrue);
    });

    test('Perkalian & Pembagian generates valid problems with × and ÷', () {
      bool foundMultiplication = false;
      bool foundDivision = false;

      for (int i = 0; i < 50; i++) {
        final problem = generator.generate('Perkalian & Pembagian', defaultSettings);
        expect(problem.questionText.isNotEmpty, isTrue);
        expect(problem.answer.isNotEmpty, isTrue);
        if (problem.questionText.contains('×')) foundMultiplication = true;
        if (problem.questionText.contains('÷')) foundDivision = true;
      }

      expect(foundMultiplication, isTrue);
      expect(foundDivision, isTrue);
    });

    test('Challenging and Expert difficulty generate valid problems without errors', () {
      final challengingSettings = defaultSettings.copyWith(difficulty: 'Challenging');
      final expertSettings = defaultSettings.copyWith(difficulty: 'Expert');

      for (var op in ['Penjumlahan', 'Pengurangan', 'Perkalian', 'Pembagian']) {
        final p1 = generator.generate(op, challengingSettings);
        expect(p1.questionText.isNotEmpty, isTrue);
        expect(p1.answer.isNotEmpty, isTrue);

        final p2 = generator.generate(op, expertSettings);
        expect(p2.questionText.isNotEmpty, isTrue);
        expect(p2.answer.isNotEmpty, isTrue);
      }
    });

    test('Advanced operations (Pangkat, Akar, Logaritma, Faktorial) remain fully functional', () {
      final pangkat = generator.generate('Pangkat', defaultSettings);
      expect(pangkat.questionText.isNotEmpty, isTrue);

      final akar = generator.generate('Akar', defaultSettings);
      expect(akar.questionText.isNotEmpty, isTrue);

      final logaritma = generator.generate('Logaritma', defaultSettings);
      expect(logaritma.questionText.isNotEmpty, isTrue);

      final faktorial = generator.generate('Faktorial', defaultSettings);
      expect(faktorial.questionText.isNotEmpty, isTrue);
    });

    test('Pembagian always produces exact integer division with no decimals for Bulat', () {
      for (int i = 0; i < 100; i++) {
        final problem = generator.generate('Pembagian', defaultSettings);
        expect(problem.answer.contains('.'), isFalse, reason: 'Division answer should be integer: ${problem.questionText} = ${problem.answer}');
        final parts = problem.questionText.split('÷').map((e) => e.trim().replaceAll('(', '').replaceAll(')', '')).toList();
        final dividend = int.parse(parts[0]);
        final divisor = int.parse(parts[1]);
        final answer = int.parse(problem.answer);
        expect(dividend ~/ divisor, equals(answer));
        expect(dividend % divisor, equals(0));
      }
    });

    test('Custom difficulty respects var2Presets digit configuration and swappable setting', () {
      final customPreset = CustomPreset(
        id: 'test_3x1',
        name: '3x1 Test',
        xDigit: 3,
        yDigit: 1,
        isSwappable: false,
      );
      final customSettings = defaultSettings.copyWith(
        difficulty: 'Custom',
        var2Presets: [customPreset],
        activeVar2PresetId: 'test_3x1',
      );

      for (int i = 0; i < 20; i++) {
        final problem = generator.generate('Penjumlahan', customSettings);
        final parts = problem.questionText.split('+').map((s) => int.parse(s.trim())).toList();
        final x = parts[0];
        final y = parts[1];
        expect(x >= 100 && x <= 999, isTrue, reason: 'X should be 3 digits (100-999): got $x');
        expect(y >= 1 && y <= 9, isTrue, reason: 'Y should be 1 digit (1-9): got $y');
      }
    });

    test('Custom difficulty for Penjumlahan & Pengurangan respects custom preset', () {
      final customPreset = CustomPreset(
        id: 'test_2x2',
        name: '2x2 Test',
        xDigit: 2,
        yDigit: 2,
        isSwappable: false,
      );
      final customSettings = defaultSettings.copyWith(
        difficulty: 'Custom',
        var2Presets: [customPreset],
        activeVar2PresetId: 'test_2x2',
      );

      for (int i = 0; i < 20; i++) {
        final problem = generator.generate('Penjumlahan & Pengurangan', customSettings);
        expect(problem.questionText.isNotEmpty, isTrue);
        expect(problem.answer.isNotEmpty, isTrue);
      }
    });
  });
}

