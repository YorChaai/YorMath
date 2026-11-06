import 'dart:math';

int safeRandomInt(Random rand, int maxVal) {
  if (maxVal <= 0) return 0;
  if (maxVal <= 4294967296) {
    return rand.nextInt(maxVal);
  } else {
    return (rand.nextDouble() * maxVal).floor();
  }
}
