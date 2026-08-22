import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/communication_service.dart';
import 'add_employee_screen.dart';
import 'machines_screen.dart';
import 'add_helper_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _whatsapp = 'regular';

  @override
  void initState() {
    super.initState();
    _loadWhatsApp();
  }

  Future<void> _loadWhatsApp() async {
    final value = await CommunicationService.getDefaultWhatsAppApp();
    if (mounted) setState(() => _whatsapp = value);
  }

  Future<void> _setWhatsApp(String value) async {
    await CommunicationService.setDefaultWhatsAppApp(value);
    if (mounted) setState(() => _whatsapp = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Administration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_add_alt_1_outlined)),
            title: const Text('Add New Employee'),
            subtitle: const Text('Create a technician account with name, employee ID, phone and PIN.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEmployeeScreen())),
          )),
          const SizedBox(height: 10),
          Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.handyman_outlined)),
            title: const Text('Helpers'),
            subtitle: const Text('Add helpers who can accompany technicians without using the app.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddHelperScreen())),
          )),
          const SizedBox(height: 10),
          Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.precision_manufacturing_outlined)),
            title: const Text('Machines'),
            subtitle: const Text('Add, edit or delete machines and equipment information.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MachinesScreen())),
          )),
          const SizedBox(height: 24),
          const Text('Android Communication', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.chat_outlined)),
            title: const Text('Default WhatsApp app'),
            subtitle: Text(_whatsapp == 'business' ? 'WhatsApp Business' : 'WhatsApp'),
            trailing: DropdownButton<String>(
              value: _whatsapp,
              underline: const SizedBox.shrink(),
              items: const [DropdownMenuItem(value: 'regular', child: Text('WhatsApp')), DropdownMenuItem(value: 'business', child: Text('WhatsApp Business'))],
              onChanged: (value) { if (value != null) _setWhatsApp(value); },
            ),
          )),
          if (kIsWeb) const Padding(padding: EdgeInsets.only(top: 8), child: Text('This preference is primarily used by the Android app.', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}
