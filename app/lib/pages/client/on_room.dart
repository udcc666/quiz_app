import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:quiz_app/db_functions.dart' as db;
import 'package:quiz_app/global.dart' as global;
import 'package:quiz_app/server_functions.dart' as server;

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
    if (global.room == null) {
      Future.microtask(() {
        if (!mounted) return;
        context.go('/client/select_room/${widget.pin}');
      });
      return;
    }
  }

  void exit() async {
    await server.client.leaveRoom(widget.pin);
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colors = theme.colorScheme;

    final quiz = global.room!.quiz!;

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: exit,
                child: Text('<- Sair'),
              ),
            ],
          ),
          Text('On room ${widget.pin}'),
          Text('Name: ${quiz.name}'),
          Text('Description: ${quiz.description}'),
          Text('Questions: ${quiz.questions.length}'),
        ],
      ),
    );
  }
}
