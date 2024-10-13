import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String ipAddress;
  final int port;
  final Function(String, int) onSave;

  const SettingsPage({
    super.key,
    required this.ipAddress,
    required this.port,
    required this.onSave,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController ipController;
  late TextEditingController portController;

  @override
  void initState() {
    super.initState();
    ipController = TextEditingController(text: widget.ipAddress);
    portController = TextEditingController(text: widget.port.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              String newIp = ipController.text;
              int newPort = int.tryParse(portController.text) ?? widget.port;

              if (newIp.isNotEmpty && newPort > 0) {
                widget.onSave(newIp, newPort);
                Navigator.pop(context);
              } else {
                print("Invalid IP or Port");
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: ipController,
              decoration: const InputDecoration(labelText: 'Adresse IP'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: portController,
              decoration: const InputDecoration(labelText: 'Port'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
