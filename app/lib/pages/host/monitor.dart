import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/classes.dart';
import 'package:quiz_app/global.dart' as global;
import 'package:quiz_app/server_functions.dart' as server;
import 'package:quiz_app/db_functions.dart' as db;

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key, required this.sessionPin});

  final String sessionPin;

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {

  Room? get room => global.room;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    if (room == null) {
      Future.microtask(tryReconnect);
      return;
    }

    checkSockets();

    setState(() {
      isLoading = false;
    });
  }

  void tryReconnect() async {
    final data = await server.host.reconnectHost(widget.sessionPin);
    
    if (!mounted) return;

    if (data['success'] == false) {
      print('error: ${data['error']}');
      context.go('/');
      return;
    }

    final dbData = await db.getSessionWithPin(data['pin']);
    if (!mounted) return;
    if (dbData['success'] == false) {
      print('error: ${dbData['error']}');
      context.go('/');
      return;
    }
    final currentSession = dbData['session'];

    global.room = Room(
      pin: data['pin'],
      name: data['quiz_name'],
      quizId: data['quiz_id'],
    );

    global.room!.settings.loadJson(currentSession);

    for (var participants in data['participants']) {
      global.room!.participants[participants['name']] = Participant(
        isOnline: participants['is_online'],
      );
    }

    checkSockets();

    setState(() {
      isLoading = false;
    });
  }

  void checkSockets() {
    global.client.onMessage.listen((data) {
      if (!mounted) return;

      if (data['type'] == 'player_joined') {
        setState(() {
          room!.participants[data['name']] = Participant(
            isOnline: true,
          );
        });
      }

      else if (data['type'] == 'player_left') {
        setState(() {
          room!.participants[data['name']].isOnline = false;
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

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
        Text('Players waiting: ${room!.numOnlinePlayers}', style: TextStyle(fontSize: 18)),
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
