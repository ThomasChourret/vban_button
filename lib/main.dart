import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vban.dart';
import 'editbuttonspage.dart';

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

