import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vban.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VBAN Button',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'VBAN Button'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> name = [];
  List<String> cmd = [];

  String ipAddress = "192.168.1.1";
  int port = 6980;

  @override
  void initState() {
    super.initState();
    _loadButtons();
  }

  Future<void> _loadButtons() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getStringList('buttonNames') ?? [];
      cmd = prefs.getStringList('buttonCmds') ?? [];
      ipAddress = prefs.getString('ipAddress') ?? "192.168.1.1";
      port = prefs.getInt('port') ?? 6980;
    });
  }

  Future<void> _saveButtons(List<String> newName, List<String> newCmd) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('buttonNames', newName);
    await prefs.setStringList('buttonCmds', newCmd);
    setState(() {
      name = newName;
      cmd = newCmd;
    });
  }

  Future<void> _saveSettings(String newIp, int newPort) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ipAddress', newIp);
    await prefs.setInt('port', newPort);
    setState(() {
      ipAddress = newIp;
      port = newPort;
      print("Settings saved: IP = $ipAddress, Port = $port");
    });
  }

  @override
  Widget build(BuildContext context) {

    Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      body: Center(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: orientation == Orientation.portrait ? 2 : 4, // Number of buttons per row
            childAspectRatio: 3, // Aspect ratio of each button
          ),
          itemCount: name.length, // Number of buttons
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  String command = cmd[index];
                  await VBAN.sendText(command, ipAddress, port);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Command sent: $command')),
                  );
                },
                child: Text(name[index]),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditButtonsPage(
                name: name,
                cmd: cmd,
                onSave: _saveButtons,
                ipAddress: ipAddress,
                port: port,
                onSaveSettings: _saveSettings,
              ),
            ),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

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
