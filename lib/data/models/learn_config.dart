enum NegativeMode { off, x, y, xy }

class LearnRange {
  final int start;
  final int end;
  LearnRange(this.start, this.end);
}

class LearnConfig {
  final int baseNumber;
  final List<LearnRange> activeRanges;
  final String operation;
  final NegativeMode negativeMode;

  LearnConfig({
    required this.baseNumber,
    required this.activeRanges,
    required this.operation,
    this.negativeMode = NegativeMode.off,
  });
}
