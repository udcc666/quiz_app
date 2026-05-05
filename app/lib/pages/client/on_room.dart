import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:quiz_app/db_functions.dart' as db;
// import 'package:quiz_app/global.dart' as global;
// import 'package:quiz_app/server_functions.dart' as server;

class OnRoomPage extends StatefulWidget {
  const OnRoomPage({super.key, required this.pin});

  final String pin;

  @override
  State<OnRoomPage> createState() => _OnRoomPageState();
}

class _OnRoomPageState extends State<OnRoomPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colors = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.go('/client/room');
                },
                child: Text('<- Voltar'),
              ),
            ],
          ),
          Text('On room ${widget.pin}'),
        ],
      ),
    );
  }
}
