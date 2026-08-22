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
                int countType(String type) => orders.where((d) => (d.data()['type'] ?? '') == type).length;
                final pmCount = countType('preventive');
                final bmCount = countType('breakdown');
                final clCount = countType('calibration');
                final adCount = countType('adjustment');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  AndroidWidgetService.update(
                    maintenanceOngoing: orders.length,
                    personEngaged: engaged,
                    personFree: free < 0 ? 0 : free,
                  );
                });
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  LayoutBuilder(builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 650 ? 2 : 1;
                    return GridView.count(crossAxisCount: columns, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: columns == 1 ? 2.4 : 1.7, children: [
                      _summaryCard('Person Available', Icons.groups_outlined, [
                        _SummaryRow('JO', '$availableTech'),
                        _SummaryRow('CF', '$availableHelpers'),
                      ]),
                      _summaryCard('Task Running', Icons.work_history_outlined, [
                        _SummaryRow('PM', '$pmCount'),
                        _SummaryRow('BM', '$bmCount'),
                        _SummaryRow('CL', '$clCount'),
                        _SummaryRow('AD', '$adCount'),
                      ]),
                    ]);
                  }),
                  const SizedBox(height: 18),
                  const Text('Available Junior Officers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

  Widget _summaryCard(String title, IconData icon, List<_SummaryRow> rows) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 10),
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    Text(row.label, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text('- ${row.value}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ]),
                )),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);
}
