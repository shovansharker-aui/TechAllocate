import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'widgets_live_activity_grid.dart';
import 'widgets_available_technicians.dart';
import 'widgets_completed_tasks_section.dart';
import 'services/android_widget_service.dart';

class AdminMonitoringPanel extends StatelessWidget {
  const AdminMonitoringPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'technician').snapshots(),
      builder: (context, techSnapshot) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('helpers').snapshots(),
          builder: (context, helperSnapshot) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('work_orders').where('status', isEqualTo: 'in_progress').snapshots(),
              builder: (context, orderSnapshot) {
                final techs = techSnapshot.data?.docs ?? [];
                final helpers = helperSnapshot.data?.docs ?? [];
                final orders = orderSnapshot.data?.docs ?? [];
                final busyTech = techs.where((d) => d.data()['status'] == 'assigned').length;
                final busyHelpers = helpers.where((d) => d.data()['status'] == 'assigned').length;
                final availableTech = techs.where((d) => d.data()['status'] != 'assigned' && d.data()['dutyStatus'] != 'on_leave').length;
                final availableHelpers = helpers.where((d) => d.data()['status'] != 'assigned').length;
                final engaged = busyTech + busyHelpers;
                final free = (techs.length + helpers.length) - engaged - techs.where((d) => d.data()['dutyStatus'] == 'on_leave').length;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  AndroidWidgetService.update(
                    maintenanceOngoing: orders.length,
                    personEngaged: engaged,
                    personFree: free < 0 ? 0 : free,
                  );
                });
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  LayoutBuilder(builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900 ? 3 : constraints.maxWidth >= 520 ? 2 : 1;
                    return GridView.count(crossAxisCount: columns, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: columns == 1 ? 4.5 : 2.4, children: [
                      _card('Available Technicians', '$availableTech', Icons.engineering_outlined),
                      _card('Running Tasks', '${orders.length}', Icons.work_history_outlined),
                      _card('Available Helpers', '$availableHelpers', Icons.handyman_outlined),
                      _card('Maintenance Ongoing', '${orders.length}', Icons.build_circle_outlined),
                      _card('Person Engaged', '$engaged', Icons.groups_outlined),
                      _card('Person Free', '${free < 0 ? 0 : free}', Icons.person_outline),
                    ]);
                  }),
                  const SizedBox(height: 18),
                  const Text('Available Technicians', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const AvailableTechnicians(),
                  const SizedBox(height: 18),
                  const Text('Running Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const LiveActivityGrid(),
                  const SizedBox(height: 18),
                  const CompletedTasksSection(),
                ]);
              },
            );
          },
        );
      },
    );
  }

  Widget _card(String title, String value, IconData icon) => Card(margin: EdgeInsets.zero, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(children: [Icon(icon, size: 24), const SizedBox(width: 8), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)), Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))]))])));
}
