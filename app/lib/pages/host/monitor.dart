import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/global.dart' as global;
import 'package:quiz_app/server_functions.dart' as server;
// import 'package:quiz_app/db_functions.dart' as db;

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key, required this.sessionPin});

  final String sessionPin;

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  int numPlayers = 0;

  @override
  void initState() {
    super.initState();
    checkSockets();
  }

  void checkSockets() {
    global.client.onMessage.listen((data) {
      if (!mounted) return;
      print('Host received: $data');
    });
  }

  void quit() async {
    await server.host.removeRoom(widget.sessionPin);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colors = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              quit();
            },
            child: Text('<- Voltar'),
          ),
          Center(child: buildWaitingScreen()),
        ],
      ),
    );
  }

  Widget buildWaitingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Players waiting: $numPlayers', style: TextStyle(fontSize: 18)),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(color: Colors.blueGrey),
        ),
        Text('Pin: ${widget.sessionPin}', style: TextStyle(fontSize: 18)),
      ],
    );
  }
}
