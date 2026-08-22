import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidWidgetService {
  static const MethodChannel _channel = MethodChannel('techallocate/widget');

  static Future<void> update({required int maintenanceOngoing, required int personEngaged, required int personFree}) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod('updateStatus', {
        'maintenanceOngoing': maintenanceOngoing,
        'personEngaged': personEngaged,
        'personFree': personFree,
      });
    } catch (_) {
      // Widget is optional; never let widget problems interrupt the app.
    }
  }
}
