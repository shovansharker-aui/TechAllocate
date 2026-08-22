import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/helper.dart';

class AddHelperScreen extends StatefulWidget {
  const AddHelperScreen({super.key});

  @override
  State<AddHelperScreen> createState() => _AddHelperScreenState();
}

class _AddHelperScreenState extends State<AddHelperScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final employeeId = _employeeIdController.text.trim();
    try {
      final existing = await FirebaseFirestore.instance
          .collection('helpers')
          .where('employeeId', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        setState(() {
          _error = 'This CF Employee ID already exists.';
          _saving = false;
        });
        return;
      }

      await FirebaseFirestore.instance.collection('helpers').add({
        'employeeId': employeeId,
        'name': _nameController.text.trim(),
        'status': 'available',
        'currentTaskId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CF added successfully.')),
      );
      Navigator.of(context).pop();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to add CF: ${e.message ?? e.code}';
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to add CF: $e';
        _saving = false;
      });
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add CF')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'CF Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Employee Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _required(v, 'Employee name'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _employeeIdController,
                    decoration: const InputDecoration(
                      labelText: 'Employee ID',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _required(v, 'Employee ID'),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'CFs do not log in to TechAllocate. They are only attached to a Junior Officer\'s active task.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add CF'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Existing CFs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('helpers').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                if (snapshot.hasError) return Text('Unable to load CFs: ${snapshot.error}');
                final helpers = snapshot.data?.docs
                        .map((d) => Helper.fromMap(d.id, d.data()))
                        .toList() ??
                    [];
                if (helpers.isEmpty) return const Text('No CFs added yet.');
                return Column(
                  children: helpers
                      .map(
                        (h) => Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text(h.name.isEmpty ? '?' : h.name[0].toUpperCase())),
                            title: Text(h.name),
                            trailing: Text(h.status == 'assigned' ? 'With JO' : 'Available'),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
