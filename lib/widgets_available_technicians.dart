import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models/app_user.dart';
import 'services/communication_service.dart';

class AvailableTechnicians extends StatelessWidget {
  const AvailableTechnicians({super.key});

  Future<void> _contact(BuildContext context, AppUser tech) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(tech.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton.filled(onPressed: () async { Navigator.pop(context); try { await CommunicationService.call(tech.phone); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); } }, icon: const Icon(Icons.call), tooltip: 'Call'),
          IconButton.filled(onPressed: () async { Navigator.pop(context); try { await CommunicationService.whatsapp(tech.phone); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); } }, icon: const Icon(Icons.chat), tooltip: 'WhatsApp'),
        ]),
      ]))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'technician').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Unable to load Junior Officers: ${snapshot.error}');
        final techs = (snapshot.data?.docs ?? []).map((d) => AppUser.fromMap(d.id, d.data())).where((t) => t.status != 'assigned' && t.dutyStatus != 'on_leave').toList();
        techs.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        if (techs.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No Junior Officer is currently available.')));
        return Card(child: Column(children: techs.map((tech) => ListTile(
          leading: CircleAvatar(child: Text(tech.name.isEmpty ? '?' : tech.name[0].toUpperCase())),
          title: Text(tech.name),
          subtitle: Text(tech.dutyStatus == 'night' ? 'Night' : 'Day'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _contact(context, tech),
        )).toList()));
      },
    );
  }
}
