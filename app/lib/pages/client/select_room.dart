import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:quiz_app/db_functions.dart' as db;
// import 'package:quiz_app/global.dart' as global;
// import 'package:quiz_app/server_functions.dart' as server;

class SelectRoomPage extends StatefulWidget {
  const SelectRoomPage({super.key, this.initialPin = '', this.errorMessage});
  
  final String initialPin;
  final String? errorMessage;

  @override
  State<SelectRoomPage> createState() => _SelectRoomPageState();
}

class _SelectRoomPageState extends State<SelectRoomPage> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pinController.text = widget.initialPin;
  }

  void tryConnect() {
    context.go('/client/room/${_pinController.text.trim().toUpperCase()}');
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
                  if (widget.errorMessage != null)
                    Text(
                      widget.errorMessage!,
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
