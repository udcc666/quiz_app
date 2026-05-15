import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/db_functions.dart' as db;
import 'package:quiz_app/global.dart' as global;
import 'package:quiz_app/imports/quiz.dart';
import 'package:quiz_app/imports/room.dart';
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
  final TextEditingController _securityController = TextEditingController();

  final FocusNode _pinFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _securityFocus = FocusNode();

  bool loading = false;
  bool validPin = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _pinController.text = widget.pin ?? '';
  }

  void tryConnect() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    String pin = _pinController.text.trim();
    String name = _nameController.text.trim();
    String securityCode = _securityController.text.trim();

    if ([pin, name, securityCode].contains('')) {
      setState(() {
        loading = false;
        validPin = false;
        errorMessage = 'Missing parameters';
      });
      return;
    }

    final data = await server.client.joinRoom(name, securityCode, pin);
    if (!mounted) return;

    if (data['success'] == false) {
      setState(() {
        loading = false;
        validPin = data['valid_room'];
        errorMessage = data['error'];
      });
      return;
    }

    final dbData = await db.getSessionWithPin(pin);
    if (!mounted) return;
    
    if (dbData['success'] == false) {
      setState(() {
        loading = false;
        validPin = false;
        errorMessage = dbData['error'];
      });
      return;
    }
    
    final currentSession = dbData['session'];

    global.room = Room(
      pin: pin,
    );
    global.room!.quiz = await Quiz.fromId(currentSession['quiz_id']);
    global.room!.loadFromJson(currentSession);

    if (!mounted) return;

    context.go('/client/room/$pin');
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
                    focusNode: _pinFocus,
                    decoration: InputDecoration(labelText: 'Pin da sala'),
                    onSubmitted: (_) {
                      _nameFocus.requestFocus();
                    },
                  ),
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    decoration: InputDecoration(labelText: 'Nome'),
                    onSubmitted: (_) {
                      _securityFocus.requestFocus();
                    },
                  ),
                  TextField(
                    controller: _securityController,
                    focusNode: _securityFocus,
                    decoration: InputDecoration(labelText: 'Codigo de segurança'),
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
