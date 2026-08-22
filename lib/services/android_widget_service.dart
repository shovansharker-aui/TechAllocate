import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidWidgetService {
  static const MethodChannel _channel = MethodChannel('techallocate/widget');

  /// Mirrors the two summary cards on the admin dashboard:
  /// "Person Available" (JO, CF) and "Task Running" (PM, BM, CL, AD).
  static Future<void> update({
    required int jo,
    required int cf,
    required int pm,
    required int bm,
    required int cl,
    required int ad,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod('updateStatus', {
        'jo': jo,
        'cf': cf,
        'pm': pm,
        'bm': bm,
        'cl': cl,
        'ad': ad,
      });
    } catch (_) {
      // Widget is optional; never let widget problems interrupt the app.
    }
  }
}