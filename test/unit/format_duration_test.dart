import 'package:flutter_test/flutter_test.dart';
import 'package:travel_journal/helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('formatDuration', () {
    test('formats zero duration as 00:00', () {
      expect(formatDuration(Duration.zero), '00:00');
    });

    test('formats 90 seconds as 01:30', () {
      expect(formatDuration(const Duration(seconds: 90)), '01:30');
    });

    test('formats 65 seconds as 01:05', () {
      expect(formatDuration(const Duration(seconds: 65)), '01:05');
    });

    test('formats 9 seconds as 00:09', () {
      expect(formatDuration(const Duration(seconds: 9)), '00:09');
    });

    test('formats 3600 seconds as 60:00', () {
      expect(formatDuration(const Duration(seconds: 3600)), '60:00');
    });
  });
}
