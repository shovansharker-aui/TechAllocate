import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunicationService {
  static const _whatsappKey = 'default_whatsapp_app';

  static Future<String> getDefaultWhatsAppApp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_whatsappKey) ?? 'regular';
  }

  static Future<void> setDefaultWhatsAppApp(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_whatsappKey, value);
  }

  static Future<void> call(String phone) async {
    final clean = phone.trim();
    if (clean.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: clean);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Unable to open the phone dialer.');
    }
  }

  static Future<void> whatsapp(String phone) async {
    var clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) return;
    // Local Bangladesh numbers are commonly stored as 01XXXXXXXXX.
    // Convert those to the international format WhatsApp expects.
    if (clean.startsWith('0')) clean = '+880${clean.substring(1)}';
    final app = await getDefaultWhatsAppApp();
    final schemes = app == 'business'
        ? ['whatsapp-business://send?phone=$clean', 'whatsapp://send?phone=$clean']
        : ['whatsapp://send?phone=$clean', 'whatsapp-business://send?phone=$clean'];

    for (final raw in schemes) {
      final uri = Uri.parse(raw);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    throw Exception('Selected WhatsApp app is not installed.');
  }

  // Reserved for a future native widget bridge. Keeping the method here makes
  // the platform-specific widget integration isolated from the UI layer.
  static const MethodChannel widgetChannel = MethodChannel('techallocate/widget');

  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}
