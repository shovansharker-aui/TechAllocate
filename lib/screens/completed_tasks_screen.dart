import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/helper.dart';
import '../models/machine.dart';
import '../models/work_order.dart';
import '../models/app_user.dart';

class CompletedTasksScreen extends StatefulWidget {
  const CompletedTasksScreen({super.key});

  @override
  State<CompletedTasksScreen> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool _isClearing = false;

  String _monthLabel(DateTime month) {
    const names = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${names[month.month - 1]} ${month.year}';
  }

  Future<void> _confirmClearMonth(DateTime monthStart, DateTime monthEnd) async {
    final query = FirebaseFirestore.instance
        .collection('work_orders')
        .where('status', isEqualTo: 'completed')
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .where('completedAt', isLessThan: Timestamp.fromDate(monthEnd));

    final countSnap = await query.count().get();
    final count = countSnap.count ?? 0;

    if (!mounted) return;
    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No completed tasks in ${_monthLabel(monthStart)}.')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Clear ${_monthLabel(monthStart)} history?'),
        content: Text('This will permanently delete $count completed task record(s) from ${_monthLabel(monthStart)}. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isClearing = true);
    try {
      final firestore = FirebaseFirestore.instance;
      // Delete in batches of 500 (Firestore's batch write limit).
      while (true) {
        final snap = await query.limit(500).get();
        if (snap.docs.isEmpty) break;
        final batch = firestore.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        if (snap.docs.length < 500) break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cleared $count task(s) from ${_monthLabel(monthStart)}.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to clear history: $e')));
      }
    } finally {
      if (mounted) setState(() => _isClearing = false);
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Unknown time';
    final local = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  String _duration(int? seconds) {
    if (seconds == null || seconds < 0) return '—';
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  String _type(WorkOrder order) {
    switch (order.type) {
      case 'preventive':
        return order.preventiveTypes.isEmpty ? 'PM' : 'PM · ${order.preventiveTypes.join(', ')}';
      case 'breakdown':
        return 'BM';
      case 'calibration':
        return 'CL';
      case 'adjustment':
        return 'AD';
      default:
        return order.type.toUpperCase();
    }
  }

  String _typeDetail(WorkOrder order) {
    if (order.type == 'preventive' && order.preventiveTypes.isNotEmpty) {
      return order.preventiveTypes.join(', ');
    }
    return '';
  }

  Future<List<AppUser>> _users() async {
    final snap = await FirebaseFirestore.instance.collection('users').get();
    return snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();
  }

  Future<List<Helper>> _helpers() async {
    final snap = await FirebaseFirestore.instance.collection('helpers').get();
    return snap.docs.map((d) => Helper.fromMap(d.id, d.data())).toList();
  }

  Future<Map<String, Machine>> _machines() async {
    final snap = await FirebaseFirestore.instance.collection('machines').get();
    return {for (final d in snap.docs) d.id: Machine.fromMap(d.id, d.data())};
  }

  Widget _taskList({required DateTime start, required DateTime end}) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('work_orders')
          .where('status', isEqualTo: 'completed')
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('completedAt', isLessThan: Timestamp.fromDate(end))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Text('Unable to load completed tasks: ${snapshot.error}');
        final orders = (snapshot.data?.docs ?? [])
            .map((d) => WorkOrder.fromMap(d.id, d.data()))
            .toList()
          ..sort((a, b) => (b.completedAt ?? DateTime(1970)).compareTo(a.completedAt ?? DateTime(1970)));
        if (orders.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No completed tasks in this period.')));

        return FutureBuilder(
          future: Future.wait([_users(), _helpers(), _machines()]),
          builder: (context, AsyncSnapshot<List<dynamic>> peopleSnapshot) {
            if (!peopleSnapshot.hasData) return const LinearProgressIndicator();
            final users = <String, AppUser>{for (final u in peopleSnapshot.data![0] as List<AppUser>) u.uid: u};
            final helpers = <String, Helper>{for (final h in peopleSnapshot.data![1] as List<Helper>) h.uid: h};
            final machines = peopleSnapshot.data![2] as Map<String, Machine>;

            return Column(
              children: orders.map((order) {
                final machine = machines[order.machineId];
                final techNames = order.assignedTechnicianIds.map((id) => users[id]?.name).whereType<String>().toList();
                final helperNames = order.helperIds.map((id) => helpers[id]?.name).whereType<String>().toList();
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: CircleAvatar(child: Text(_type(order).split(' ').first)),
                    title: Text(machine?.equipmentName ?? order.machineId, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text([
                      if (_typeDetail(order).isNotEmpty) _typeDetail(order),
                      _formatDate(order.completedAt),
                      _duration(order.durationSeconds),
                    ].join(' · ')),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    children: [
                      if (techNames.isNotEmpty) ListTile(dense: true, leading: const Icon(Icons.engineering_outlined), title: Text('JO: ${techNames.join(', ')}')),
                      if (helperNames.isNotEmpty) ListTile(dense: true, leading: const Icon(Icons.handyman_outlined), title: Text('CF: ${helperNames.join(', ')}')),
                      if (machine?.equipmentId.isNotEmpty == true) ListTile(dense: true, leading: const Icon(Icons.badge_outlined), title: Text('Equipment: ${machine!.equipmentId}')),
                      if (order.description.isNotEmpty) ListTile(dense: true, leading: const Icon(Icons.notes_outlined), title: Text('Start remarks: ${order.description}')),
                      if (order.completionRemarks.isNotEmpty) ListTile(dense: true, leading: const Icon(Icons.check_circle_outline), title: Text('Completion remarks: ${order.completionRemarks}')),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthStart = _month;
    final monthEnd = DateTime(_month.year, _month.month + 1);
    final last24 = DateTime.now().subtract(const Duration(hours: 24));
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Tasks')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Last 24 Hours', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _taskList(start: last24, end: DateTime.now().add(const Duration(minutes: 1))),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(child: Text('Monthly History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)), icon: const Icon(Icons.chevron_left)),
              Text('${_month.year}-${_month.month.toString().padLeft(2, '0')}'),
              IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)), icon: const Icon(Icons.chevron_right)),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _isClearing ? null : () => _confirmClearMonth(monthStart, monthEnd),
              icon: _isClearing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.delete_outline, size: 18),
              label: Text('Clear ${_monthLabel(monthStart)} history'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
          const SizedBox(height: 8),
          _taskList(start: monthStart, end: monthEnd),
        ],
      ),
    );
  }
}
