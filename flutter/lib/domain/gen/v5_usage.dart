class V5Usage {
  const V5Usage({
    required this.percent,
    required this.timeUntilNextPercent,
    required this.isNegative,
  });

  factory V5Usage.fromJson(Map<String, dynamic> json) {
    final percent = json['percent'];
    final timeUntilNextPercent = json['timeUntilNextPercent'];

    if (percent is! num || timeUntilNextPercent is! num) {
      throw const FormatException('Invalid V5 usage response');
    }

    return V5Usage(
      percent: percent.toDouble(),
      timeUntilNextPercent: timeUntilNextPercent.toInt(),
      isNegative: json['isNegative'] == true,
    );
  }

  final double percent;
  final int timeUntilNextPercent;
  final bool isNegative;

  double get remainingPercent => isNegative ? 0 : percent.clamp(0, 100);

  double get refillPercentPerHour {
    if (timeUntilNextPercent <= 0) return 0;
    return 3600 / timeUntilNextPercent;
  }

  Duration get timeUntilFull {
    if (timeUntilNextPercent <= 0) return Duration.zero;

    final percentToRefill = isNegative ? percent + 100 : 100 - percent;
    return Duration(
      seconds:
          (percentToRefill.clamp(0, double.infinity) * timeUntilNextPercent)
              .round(),
    );
  }

  int get minutesUntilFull {
    if (remainingPercent >= 100) return 0;
    final seconds = timeUntilFull.inSeconds;
    if (seconds <= 0) return 0;
    return (seconds / 60).ceil();
  }

  String get timeUntilFullLabel {
    final duration = timeUntilFull;
    if (duration == Duration.zero) return '계산 중';

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    if (days > 0) return '$days일 $hours시간';
    if (hours > 0) return '$hours시간 $minutes분';
    return '$minutes분';
  }
}
