import 'package:flutter_test/flutter_test.dart';
import 'package:ai_based_smart_energy_meter/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('NotificationViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
