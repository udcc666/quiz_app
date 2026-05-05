import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:quiz_app/db_functions.dart' as db;
// import 'package:quiz_app/global.dart' as global;
import 'package:quiz_app/server_functions.dart' as server;

class SelectRoomPage extends StatefulWidget {
  const SelectRoomPage({super.key});

  @override
  State<SelectRoomPage> createState() => _SelectRoomPageState();
}

class _SelectRoomPageState extends State<SelectRoomPage> {

  final TextEditingController _pinController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
  }

  void tryConnect() async {
    String pin = _pinController.text.trim();

    final data = await server.client.joinRoom('Jorge', pin);

    print(data);
    
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
                  context.go('/');
                },
                child: Text('<- Voltar'),
              ),
            ],
          ),
          Column(
            children: [
              TextField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: 'Pin da sala',
                ),
              ),
              FilledButton(
                onPressed: tryConnect,
                child: Text('Entrar na sala'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
