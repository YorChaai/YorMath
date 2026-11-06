// sequence generator untuk dual n-back
// generate posisi (0-8) dan huruf (A-Z) dengan controlled match probability
import 'dart:math';

class SequenceItem {
  final int position; // 0-8 (3x3 grid)
  final String letter; // A-Z

  const SequenceItem({required this.position, required this.letter});
}

class SequenceGenerator {
  static const int gridSize = 9; // 3x3
  static const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const double matchProbability = 0.25; // 25% chance of match

  final Random _random = Random();

  /// generate sequence dengan controlled match probability
  /// [length] = jumlah trial
  /// [nLevel] = berapa langkah ke belakang yang harus diingat
  List<SequenceItem> generate(int length, int nLevel) {
    final positions = _generateStream(
      length: length,
      nLevel: nLevel,
      totalOptions: gridSize,
    );

    final letters = _generateStream(
      length: length,
      nLevel: nLevel,
      totalOptions: alphabet.length,
    );

    return List.generate(
      length,
      (i) => SequenceItem(position: positions[i], letter: alphabet[letters[i]]),
    );
  }

  /// generate satu stream (posisi atau huruf) dengan match probability
  List<int> _generateStream({
    required int length,
    required int nLevel,
    required int totalOptions,
  }) {
    final stream = <int>[];

    for (int i = 0; i < length; i++) {
      if (i < nLevel) {
        // belum cukup history, pilih random
        stream.add(_random.nextInt(totalOptions));
      } else {
        final shouldMatch = _random.nextDouble() < matchProbability;

        if (shouldMatch) {
          // match: sama dengan N langkah lalu
          stream.add(stream[i - nLevel]);
        } else {
          // non-match: pilih random tapi pastikan TIDAK sama dengan N langkah lalu
          int value;
          do {
            value = _random.nextInt(totalOptions);
          } while (value == stream[i - nLevel]);
          stream.add(value);
        }
      }
    }

    return stream;
  }

  /// hitung jumlah match yang expected dalam sequence
  static int expectedMatches(int length, int nLevel) {
    final matchableTrials = length - nLevel;
    return (matchableTrials * matchProbability).round();
  }
}
