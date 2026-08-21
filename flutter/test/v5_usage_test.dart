import 'package:flutter_test/flutter_test.dart';
import 'package:naiapp/domain/gen/v5_usage.dart';

void main() {
  test('parses active V5 allowance and calculates the refill rate', () {
    final usage = V5Usage.fromJson({
      'percent': 98.5,
      'timeUntilNextPercent': 7200,
      'isNegative': false,
    });

    expect(usage.remainingPercent, 98.5);
    expect(usage.refillPercentPerHour, 0.5);
    expect(usage.minutesUntilFull, 180);
    expect(usage.timeUntilFull, const Duration(hours: 3));
  });

  test('shows zero remaining when the allowance is exhausted', () {
    final usage = V5Usage.fromJson({
      'percent': 0,
      'timeUntilNextPercent': 7200,
      'isNegative': true,
    });

    expect(usage.remainingPercent, 0);
  });

  test('reports zero minutes until full for a full allowance', () {
    final usage = V5Usage.fromJson({
      'percent': 100,
      'timeUntilNextPercent': 60,
      'isNegative': false,
    });

    expect(usage.refillPercentPerHour, 60);
    expect(usage.minutesUntilFull, 0);
  });
}
