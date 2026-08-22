import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../widgets_admin_monitoring_panel.dart';
import 'settings_screen.dart';
import '../widgets_root_back_scope.dart';

class AdminDashboardScreen extends StatelessWidget {
  final AppUser user;
  final VoidCallback onLogout;
  const AdminDashboardScreen({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return RootBackScope(child: Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), actions: [
        IconButton(icon: const Icon(Icons.settings_outlined), tooltip: 'Settings', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        IconButton(icon: const Icon(Icons.logout), tooltip: 'Log out', onPressed: onLogout),
      ]),
      body: RefreshIndicator(onRefresh: () async {}, child: const SingleChildScrollView(padding: EdgeInsets.all(12), child: AdminMonitoringPanel())),
    ));
  }
}
