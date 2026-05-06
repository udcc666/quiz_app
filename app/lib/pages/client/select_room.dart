import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:quiz_app/db_functions.dart' as db;
// import 'package:quiz_app/global.dart' as global;
import 'package:quiz_app/server_functions.dart' as server;

class SelectRoomPage extends StatefulWidget {
  const SelectRoomPage({super.key, this.pin});

  final String? pin;

  @override
  State<SelectRoomPage> createState() => _SelectRoomPageState();
}

class _SelectRoomPageState extends State<SelectRoomPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool loading = false;
  bool validPin = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _pinController.text = widget.pin ?? '';
  }

  void tryConnect({bool isFirstCheck = false}) async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    String pin = _pinController.text.trim();
    String name = _nameController.text.trim();

    final data = await server.client.joinRoom(name, pin);

    if (data['success']) {
      if (!mounted) return;
      context.go('/client/room/${pin}');
      return;
    }

    setState(() {
      loading = false;
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
          Flexible(
            child: Padding(
              padding: EdgeInsetsGeometry.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: colors.onError,
                        backgroundColor: colors.error,
                      ),
                    ),
                  TextField(
                    controller: _pinController,
                    decoration: InputDecoration(labelText: 'Pin da sala'),
                    onSubmitted: (_) {
                      tryConnect();
                    },
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nome'),
                    onSubmitted: (_) {
                      tryConnect();
                    },
                  ),
                  FilledButton(
                    onPressed: tryConnect,
                    child: Text('Entrar na sala'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
