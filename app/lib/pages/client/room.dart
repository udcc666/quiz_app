import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/pages/client/on_room.dart';
import 'package:quiz_app/pages/client/select_room.dart';
// import 'package:quiz_app/db_functions.dart' as db;
// import 'package:quiz_app/global.dart' as global;
import 'package:quiz_app/server_functions.dart' as server;

class RoomPage extends StatefulWidget {
  const RoomPage({super.key, this.pin});

  final String? pin;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final TextEditingController _nameController = TextEditingController();

  bool validPin = false;
  bool loading = false;
  bool connected = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController.text = '';
    tryConnect(isFirstCheck: true);
  }

  void tryConnect({bool isFirstCheck = false}) async {
    if (widget.pin == null || loading) return;

    setState(() {
      loading = true;
    });

    String pin = widget.pin!.trim();
    String name = _nameController.text.trim();

    final data = await server.client.joinRoom(name, pin);

    setState(() {
      loading = false;
      connected = data['success'];
      validPin = data['valid_room'];
      errorMessage = data['error'];
      if (isFirstCheck) {
        if (validPin) {
          errorMessage = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!validPin) {
      return SelectRoomPage(
        initialPin: widget.pin ?? '',
        errorMessage: errorMessage
      );
    }
    if (connected) {
      return OnRoomPage(pin: widget.pin!);
    }
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.go('/client/select_room');
                },
                child: Text('<- Voltar'),
              ),
            ],
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsetsGeometry.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Text('Entrar na sala ${widget.pin}'),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nome'),
                    onSubmitted: (_) {
                      tryConnect();
                    },
                  ),
                  ElevatedButton(onPressed: tryConnect, child: Text('Entrar')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
