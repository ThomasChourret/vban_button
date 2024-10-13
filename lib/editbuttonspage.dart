import 'package:flutter/material.dart';
import 'settingspage.dart';

class EditButtonsPage extends StatefulWidget {
  final List<String> name;
  final List<String> cmd;
  final Function(List<String>, List<String>) onSave;
  final String ipAddress;
  final int port;
  final Function(String, int) onSaveSettings;

  const EditButtonsPage({
    super.key,
    required this.name,
    required this.cmd,
    required this.onSave,
    required this.ipAddress,
    required this.port,
    required this.onSaveSettings,
  });

  @override
  _EditButtonsPageState createState() => _EditButtonsPageState();
}

class _EditButtonsPageState extends State<EditButtonsPage> {
  late List<TextEditingController> nameControllers;
  late List<TextEditingController> cmdControllers;

  @override
  void initState() {
    super.initState();
    nameControllers =
        widget.name.map((name) => TextEditingController(text: name)).toList();
    cmdControllers =
        widget.cmd.map((cmd) => TextEditingController(text: cmd)).toList();
  }

  void _addButton() {
    setState(() {
      nameControllers.add(TextEditingController());
      cmdControllers.add(TextEditingController());
    });
  }

  void _removeButton(int index) {
    setState(() {
      nameControllers.removeAt(index);
      cmdControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Buttons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              List<String> newName =
                  nameControllers.map((controller) => controller.text).toList();
              List<String> newCmd =
                  cmdControllers.map((controller) => controller.text).toList();
              widget.onSave(newName, newCmd);
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    ipAddress: widget.ipAddress,
                    port: widget.port,
                    onSave: (newIp, newPort) {
                      widget.onSaveSettings(newIp, newPort);
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(onPressed: _addButton, icon: const Icon(Icons.add)),
        ],
      ),
      body: ListView.builder(
        itemCount: nameControllers.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameControllers[index],
                    decoration: const InputDecoration(labelText: 'Button Name'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: cmdControllers[index],
                    decoration: const InputDecoration(labelText: 'Command'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeButton(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}