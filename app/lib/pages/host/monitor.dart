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
      if (data['type'] == 'player_joined') {
        setState(() {
          numPlayers++;
        });
      }
      else if (data['type'] == 'player_left') {
        setState(() {
          numPlayers--;
        });
      }

    });
  }

  void closeRoom() async {
    await server.host.removeRoom(widget.sessionPin);
    if (!mounted) return;
    goBack();
  }

  void goBack() {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: goBack,
                child: Text('<- Voltar'),
              ),
              TextButton(
                onPressed: closeRoom,
                style: TextButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                ),
                child: Text('Close Room'),
              ),
            ],
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
