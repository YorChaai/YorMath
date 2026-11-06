import 'dart:math';
import '../../data/models/math_problem.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/learn_config.dart';

import 'generators/basic_generator.dart';
import 'generators/decimal_generator.dart';
import 'generators/root_power_generator.dart';

class MathGenerator {
  final Random _rand = Random();

  final BasicGenerator _basicGen = BasicGenerator();
  final DecimalGenerator _decGen = DecimalGenerator();
  final RootPowerGenerator _rpGen = RootPowerGenerator();

  MathProblem generate(String operation, AppSettings settings, {LearnConfig? learnConfig}) {
    if (learnConfig != null) {
      return _generateForLearn(learnConfig);
    }

    int min1 = 1, max1 = 9, min2 = 1, max2 = 9;
    int? activeThreshold;
    int? activeDecimalPlaces;
    bool activeRandomDecimal = false;

    if (settings.difficulty == 'Custom') {
      bool isOneVar = ['Faktorial', 'Nilai Mutlak'].contains(operation);
      bool isOtherVar = ['Akar', 'Pangkat', 'Logaritma'].contains(operation);
      
      if (isOtherVar) {
        final p = settings.otherPresets.firstWhere(
          (p) => p.id == settings.activeOtherPresetId, 
          orElse: () => CustomPreset(id: '', name: '', xDigit: 1, baseDigit: 10, akarLimit: 20, pangkatLimit: 5)
        );
        int baseLimit = p.baseDigit ?? 10;
        max1 = baseLimit;
        min1 = 1;
        max2 = 1; min2 = 1;
        activeThreshold = p.maxThreshold;
        activeDecimalPlaces = p.decimalPlaces;
        activeRandomDecimal = p.isRandomDecimalDigits;
      } else if (isOneVar) {
        final p = settings.var1Presets.firstWhere((p) => p.id == settings.activeVar1PresetId, orElse: () => CustomPreset(id: '', name: '', xDigit: 1));
        max1 = pow(10, p.xDigit).toInt() - 1;
        min1 = p.xDigit == 1 ? 1 : pow(10, p.xDigit - 1).toInt();
        max2 = 1; min2 = 1;
        activeThreshold = p.maxThreshold;
        activeDecimalPlaces = p.decimalPlaces;
        activeRandomDecimal = p.isRandomDecimalDigits;
      } else {
        final p = settings.var2Presets.firstWhere((p) => p.id == settings.activeVar2PresetId, orElse: () => CustomPreset(id: '', name: '', xDigit: 1, yDigit: 1));
        max1 = pow(10, p.xDigit).toInt() - 1;
        min1 = p.xDigit == 1 ? 1 : pow(10, p.xDigit - 1).toInt();
        int limitY = p.yDigit ?? 1;
        max2 = pow(10, limitY).toInt() - 1;
        min2 = limitY == 1 ? 1 : pow(10, limitY - 1).toInt();
        
        if (p.isSwappable && _rand.nextBool()) {
          int tempMin = min1;
          int tempMax = max1;
          min1 = min2;
          max1 = max2;
          min2 = tempMin;
          max2 = tempMax;
        }
        
        activeThreshold = p.maxThreshold;
        activeDecimalPlaces = p.decimalPlaces;
        activeRandomDecimal = p.isRandomDecimalDigits;
      }
    } else {
      int digits = 1;
      if (settings.difficulty == 'Medium') digits = 2;
      if (settings.difficulty == 'Hard') digits = 3;
      if (settings.difficulty == 'Challenging') digits = 3;
      if (settings.difficulty == 'Expert' || settings.difficulty == 'Extreme') digits = 4;
      max1 = pow(10, digits).toInt() - 1;
      min1 = digits == 1 ? 1 : pow(10, digits - 1).toInt();
      max2 = max1;
      min2 = min1;
    }

    switch (operation) {
      case 'Penjumlahan':
      case 'Pengurangan':
      case 'Perkalian':
      case 'Pembagian':
      case 'Perbandingan':
      case 'Persentase':
      case 'Faktorial':
      case 'Nilai Mutlak':
      case 'Modulo':
        return _basicGen.generate(operation, settings, min1, max1, min2, max2, threshold: activeThreshold, decimalPlaces: activeDecimalPlaces, isRandomDecimalDigits: activeRandomDecimal);
      
      case 'Logaritma':
        bool isCampuranLog = false;
        bool addSubLog = true;
        bool mulDivLog = true;
        if (settings.difficulty == 'Custom') {
          final p = settings.otherPresets.firstWhere((p) => p.id == settings.activeOtherPresetId, orElse: () => CustomPreset(id: '', name: '', xDigit: 1));
          isCampuranLog = p.isCampuranLainLain;
          addSubLog = p.allowCampuranAddSub;
          mulDivLog = p.allowCampuranMulDiv;
        }
        return _rpGen.generateLogarithm(settings, isCampuranLog, addSubLog, mulDivLog);
      
      case 'Desimal':
        int precision = 1;
        if (settings.difficulty == 'Custom') {
          final p = settings.var2Presets.firstWhere((p) => p.id == settings.activeVar2PresetId, orElse: () => CustomPreset(id: '', name: '', xDigit: 1, yDigit: 1));
          precision = p.decimalPlaces ?? p.yDigit ?? 1;
        } else {
          precision = settings.difficulty == 'Hard' ? 2 : (settings.difficulty == 'Extreme' ? 3 : 1);
        }
        return _decGen.generate(settings, max1, precision);
      
      case 'Akar':
        int akarLim = 20;
        bool isCampuranAkar = false;
        bool addSubAkar = true;
        bool mulDivAkar = true;
        if (settings.difficulty == 'Custom') {
          final p = settings.otherPresets.firstWhere((p) => p.id == settings.activeOtherPresetId, orElse: () => CustomPreset(id: '', name: '', xDigit: 1, akarLimit: 20));
          akarLim = p.akarLimit ?? 20;
          isCampuranAkar = p.isCampuranLainLain;
          addSubAkar = p.allowCampuranAddSub;
          mulDivAkar = p.allowCampuranMulDiv;
        }
        return _rpGen.generateRoot(settings, max1, akarLim, isCampuranAkar, addSubAkar, mulDivAkar);
      
      case 'Pangkat':
        int pangkatLim = 5;
        bool isCampuranPangkat = false;
        bool addSubPangkat = true;
        bool mulDivPangkat = true;
        if (settings.difficulty == 'Custom') {
          final p = settings.otherPresets.firstWhere((p) => p.id == settings.activeOtherPresetId, orElse: () => CustomPreset(id: '', name: '', xDigit: 1, pangkatLimit: 5));
          pangkatLim = p.pangkatLimit ?? 5;
          isCampuranPangkat = p.isCampuranLainLain;
          addSubPangkat = p.allowCampuranAddSub;
          mulDivPangkat = p.allowCampuranMulDiv;
        }
        return _rpGen.generatePower(settings, max1, pangkatLim, isCampuranPangkat, addSubPangkat, mulDivPangkat);
      
      case 'Penjumlahan & Pengurangan':
        final addSubOps = ['Penjumlahan', 'Pengurangan'];
        return generate(addSubOps[_rand.nextInt(addSubOps.length)], settings);

      case 'Perkalian & Pembagian':
        final mulDivOps = ['Perkalian', 'Pembagian'];
        return generate(mulDivOps[_rand.nextInt(mulDivOps.length)], settings);

      case 'Aritmetika Campuran':
        final ops = ['Penjumlahan', 'Pengurangan', 'Perkalian', 'Pembagian'];
        return generate(ops[_rand.nextInt(ops.length)], settings);
        
      case 'Custom Mixed':
        final ops = settings.customMixedOperations.isNotEmpty 
            ? settings.customMixedOperations 
            : ['Penjumlahan', 'Pengurangan', 'Perkalian', 'Pembagian'];
        return generate(ops[_rand.nextInt(ops.length)], settings);
      
      default:
        return _basicGen.generate('Penjumlahan', settings, min1, max1, min2, max2, threshold: activeThreshold, decimalPlaces: activeDecimalPlaces, isRandomDecimalDigits: activeRandomDecimal);
    }
  }

  MathProblem _generateForLearn(LearnConfig config) {
    List<int> validNumbers = [];
    for (var r in config.activeRanges) {
      for (int i = r.start; i <= r.end; i++) {
        validNumbers.add(i);
      }
    }
    if (validNumbers.isEmpty) {
      for (int i = 1; i <= 10; i++) {
        validNumbers.add(i);
      }
    }

    int base = config.baseNumber;
    int rangeValue = validNumbers[_rand.nextInt(validNumbers.length)];

    if (config.negativeMode == NegativeMode.x || config.negativeMode == NegativeMode.xy) base = -base;
    if (config.negativeMode == NegativeMode.y || config.negativeMode == NegativeMode.xy) rangeValue = -rangeValue;
    
    Map<String, dynamic> meta = {
      'operation': config.operation, 'base': base, 'rangeVal': rangeValue,
    };

    switch (config.operation) {
      case 'Penjumlahan':
      case 'Pertambahan':
        return MathProblem(questionText: '$base + ${rangeValue < 0 ? '($rangeValue)' : rangeValue}', answer: '${base + rangeValue}', metadata: meta);
      case 'Pengurangan':
        int startVal = base + rangeValue;
        return MathProblem(questionText: '$startVal - ${base < 0 ? '($base)' : base}', answer: '$rangeValue', metadata: meta);
      case 'Perkalian':
        return MathProblem(questionText: '$base × ${rangeValue < 0 ? '($rangeValue)' : rangeValue}', answer: '${base * rangeValue}', metadata: meta);
      case 'Pembagian':
        if (base == 0) base = 1;
        int product = base * rangeValue;
        return MathProblem(questionText: '$product ÷ ${base < 0 ? '($base)' : base}', answer: '$rangeValue', metadata: meta);
      case 'Pangkat':
        String bStr = base < 0 ? '($base)' : '$base';
        String rStr = rangeValue < 0 ? '($rangeValue)' : '$rangeValue';
        return MathProblem(questionText: '$bStr^$rStr', answer: '${pow(base, rangeValue).toInt()}', metadata: meta);
      case 'Akar':
        int rootIndex = base == 0 ? 2 : base;
        int inner = pow(rangeValue.abs(), rootIndex).toInt();
        String qText = rootIndex == 3 ? '∛$inner' : '√$inner';
        return MathProblem(questionText: qText, answer: '${rangeValue.abs()}', metadata: meta);
      case 'Logaritma':
        int logBase = base <= 1 ? 2 : base;
        int exp = rangeValue < 1 ? 1 : rangeValue;
        int inner = pow(logBase, exp).toInt();
        return MathProblem(questionText: 'log_$logBase($inner)', answer: '$exp', metadata: meta);
      case 'Modulo':
        int modBase = base == 0 ? 1 : base.abs();
        return MathProblem(questionText: '$rangeValue mod $modBase', answer: '${rangeValue % modBase}', metadata: meta);
      case 'Faktorial':
        int n = rangeValue.abs().clamp(1, 8);
        int fact = 1;
        for (int i = 1; i <= n; i++) {
          fact *= i;
        }
        return MathProblem(questionText: '$n!', answer: '$fact', metadata: meta);
      case 'Nilai Mutlak':
        return MathProblem(questionText: '|$rangeValue|', answer: '${rangeValue.abs()}', metadata: meta);
      case 'Persentase':
        int val = rangeValue;
        double result = val / 100;
        String ans = result == result.toInt() ? '${result.toInt()}' : (result * 100 == (result * 100).toInt() ? (result).toString() : result.toStringAsFixed(2));
        return MathProblem(questionText: '$val%', answer: ans, metadata: meta);
      case 'Perbandingan':
        return MathProblem(questionText: '$base : $rangeValue = ${base * 2} : ?', answer: '${rangeValue * 2}', metadata: meta);
      default:
        return MathProblem(questionText: '$base + ${rangeValue < 0 ? '($rangeValue)' : rangeValue}', answer: '${base + rangeValue}', metadata: meta);
    }
  }
}

