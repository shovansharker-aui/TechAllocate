import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  bool _isSaving = false;
  bool _hidePin = true;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final employeeId = _employeeIdController.text.trim();
    final firestore = FirebaseFirestore.instance;

    try {
      final existing = await firestore
          .collection('users')
          .where('employeeId', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        setState(() {
          _errorText = 'This Employee ID already exists.';
          _isSaving = false;
        });
        return;
      }

      await firestore.collection('users').add({
        'name': _nameController.text.trim(),
        'employeeId': employeeId,
        'phone': _phoneController.text.trim(),
        'pin': _pinController.text.trim(),
        'role': 'technician',
        'trade': '',
        'shift': '',
        'status': 'available',
        'dutyStatus': 'day',
        'currentTaskId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee added successfully.')),
      );
      Navigator.of(context).pop();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Failed to add employee: ${e.message ?? e.code}';
        _isSaving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Failed to add employee: $e';
        _isSaving = false;
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
      appBar: AppBar(title: const Text('Add New Employee')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Employee Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Employee Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _required(value, 'Employee name'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _employeeIdController,
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _required(value, 'Employee ID'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _required(value, 'Phone number'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _pinController,
                  obscureText: _hidePin,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _hidePin = !_hidePin),
                      icon: Icon(
                        _hidePin ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final error = _required(value, 'PIN');
                    if (error != null) return error;
                    if (!RegExp(r'^\d+$').hasMatch(value!.trim())) {
                      return 'PIN must contain numbers only.';
                    }
                    if (value.trim().length < 4) {
                      return 'PIN must be at least 4 digits.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'New employees are created as Junior Officers.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 18),
                if (_errorText != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveEmployee,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Employee'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
