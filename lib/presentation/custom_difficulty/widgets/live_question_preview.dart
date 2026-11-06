import 'dart:math';
import 'package:flutter/material.dart';

class LiveQuestionPreview extends StatelessWidget {
  final int presetType;
  final int xDigit;
  final int? yDigit;
  final int? baseDigit;
  final int? akarLimit;
  final int? pangkatLimit;
  final int? decimalPlaces;
  final bool isRandomDecimalDigits;
  final int? maxThreshold;

  const LiveQuestionPreview({
    super.key,
    required this.presetType,
    required this.xDigit,
    this.yDigit,
    this.baseDigit,
    this.akarLimit,
    this.pangkatLimit,
    this.decimalPlaces,
    this.isRandomDecimalDigits = false,
    this.maxThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final samples = _generateSamples();

    return Container(
      margin: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header outside the box to prevent overflow
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 15,
                  color: isDark ? const Color(0xFF80D8FF) : const Color(0xFF0288D1),
                ),
                const SizedBox(width: 6),
                Text(
                  'Pratinjau Soal:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF80D8FF) : const Color(0xFF0288D1),
                  ),
                ),
              ],
            ),
          ),
          // Content box containing only the equations
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFF86EFAC),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: samples.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF80D8FF) : const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: isDark ? Colors.grey.shade200 : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateSamples() {
    if (presetType == 2) {
      final yD = yDigit ?? xDigit;
      if (decimalPlaces != null && decimalPlaces! > 0) {
        if (isRandomDecimalDigits) {
          if (decimalPlaces == 3) {
            return [
              '0.70 + 0.456 = ?',
              '0.345 × 0.1 = ?',
            ];
          } else if (decimalPlaces == 2) {
            return [
              '0.7 + 0.48 = ?',
              '0.35 × 0.2 = ?',
            ];
          } else if (decimalPlaces! >= 4) {
            return [
              '0.450 + 0.1234 = ?',
              '0.7892 × 0.5 = ?',
            ];
          }
          return [
            '0.7 + 4.80 = ?',
            '0.35 × 0.2 = ?',
          ];
        } else {
          final dec = decimalPlaces!;
          final xSample = _sampleForDigit(xDigit, 48);
          final ySample = _sampleForDigit(yD, 7);
          final xFormatted = (xSample / pow(10, min(dec, 2))).toStringAsFixed(dec);
          final yFormatted = (ySample / pow(10, min(dec, 1))).toStringAsFixed(dec);
          return [
            '$xFormatted + $yFormatted = ?',
            '$xFormatted × $ySample = ?',
          ];
        }
      }
      final xSample = _sampleForDigit(xDigit, 48);
      final ySample = _sampleForDigit(yD, 7);
      return [
        '$xSample + $ySample = ${xSample + ySample}',
        '$xSample × $ySample = ${xSample * ySample}',
      ];
    } else if (presetType == 1) {
      if (xDigit <= 1) {
        return ['5! = 120', '| -8 | = 8', '7! = 5040'];
      } else {
        final xSample = _sampleForDigit(xDigit, 25);
        return ['| -$xSample | = $xSample', '$xSample! (Batas: ${maxThreshold ?? 505})'];
      }
    } else if (presetType == 3) {
      final pLimit = pangkatLimit ?? 5;
      final aLimit = akarLimit ?? 20;
      return [
        '4^${pLimit > 2 ? 2 : pLimit} = 16',
        '√${(aLimit >= 9 ? 9 : 4) * (aLimit >= 9 ? 9 : 4)} = ${aLimit >= 9 ? 9 : 4}',
        'log₁₀(100) = 2',
      ];
    } else {
      final xSample = _sampleForDigit(xDigit, 15);
      return [
        'Mulai dari $xSample ➔ + 8 ➔ - 5 ➔ = ${xSample + 8 - 5}',
        'Mulai dari $xSample ➔ × 2 ➔ + 6 ➔ = ${xSample * 2 + 6}',
      ];
    }
  }

  int _sampleForDigit(int digit, int fallback) {
    if (digit == 1) return 7;
    if (digit == 2) return 48;
    if (digit == 3) return 325;
    if (digit == 4) return 1420;
    if (digit == 5) return 25400;
    return fallback;
  }
}
