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

  // Méthode pour réorganiser les boutons
  void _reorderButtons(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String movedName = nameControllers[oldIndex].text;
      final String movedCmd = cmdControllers[oldIndex].text;
      nameControllers.removeAt(oldIndex);
      cmdControllers.removeAt(oldIndex);
      nameControllers.insert(newIndex, TextEditingController(text: movedName));
      cmdControllers.insert(newIndex, TextEditingController(text: movedCmd));
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
      body: ReorderableListView(
        onReorder: _reorderButtons,
        children: List.generate(nameControllers.length, (index) {
          return Card(
            key: ValueKey(index),
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Icône pour réorganiser
                  IconButton(
                    icon: const Icon(Icons.drag_handle),
                    onPressed: null, // Aucune action ici
                  ),
                  const SizedBox(width: 8),
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
            ),
          );
        }),
      ),
    );
  }
}
