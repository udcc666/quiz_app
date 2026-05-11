import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/imports/classes.dart';
import 'package:quiz_app/imports/quiz.dart';
import 'package:quiz_app/imports/room.dart';
import 'package:quiz_app/db_functions.dart' as db;
import 'package:quiz_app/global.dart' as global;
import 'package:quiz_app/server_functions.dart' as server;

class SearchOwnedRoomsPage extends StatefulWidget {
  const SearchOwnedRoomsPage({super.key});

  @override
  State<SearchOwnedRoomsPage> createState() => _SearchOwnedRoomsPageState();
}

class _SearchOwnedRoomsPageState extends State<SearchOwnedRoomsPage> {
  String? sessionErrorMessage;

  bool loading = true;
  List<dynamic> sessions = [];
  Map<String, dynamic> sessionsByName = {};

  String? selectedQuizName;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  void loadSessions() async {
    setState(() {
      loading = true;
    });

    final data = await db.getOwnedRooms(global.userId!);

    if (!mounted) return;

    if (data['success'] == false) {
      setState(() {
        sessionErrorMessage = data['error'];
        loading = false;
      });
      return;
    }

    sessions = data['sessions'];
    sessionErrorMessage = null;

    for (var session in sessions) {
      String quizName = session['quiz_name'];
      if (sessionsByName.containsKey(quizName)) {
        sessionsByName[quizName]!.add(session);
      } else {
        sessionsByName[quizName] = [session];
      }
    }

    setState(() {
      loading = false;
    });
  }

  void tryReconnect(String pin) async {
    final data = await server.host.reconnectHost(pin);
    
    if (!mounted) return;

    if (data['success'] == false) {
      debugPrint('error: ${data['error']}');
      context.go('/');
      return;
    }

    final dbData = await db.getSessionWithPin(data['pin']);
    if (!mounted) return;
    if (dbData['success'] == false) {
      debugPrint('error: ${dbData['error']}');
      context.go('/');
      return;
    }
    final currentSession = dbData['session'];

    global.room = Room(
      pin: data['pin'],
    );
    global.room!.quiz = await Quiz.fromId(currentSession['quiz_id']);

    global.room!.settings.loadJson(currentSession);

    for (var participants in data['participants']) {
      global.room!.participants[participants['name']] = Participant(
        isOnline: participants['is_online'],
      );
    }

    if (!mounted) return;
    context.go('/host/monitor/$pin');

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

          if (loading) ...[
            Flexible(child: Center(child: CircularProgressIndicator())),
          ] else ...[
            buildList(),
          ],
        ],
      ),
    );
  }

  Widget buildList() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (sessions.isEmpty) {
      return Text(
        'Nenhuma sala encontrada.',
        style: TextStyle(
          backgroundColor: colors.primaryContainer,
          color: colors.onPrimaryContainer,
        ),
      );
    }

    return Flexible(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          spacing: 10,
          children: [
            if (sessionErrorMessage != null)
              Text(
                sessionErrorMessage!,
                style: TextStyle(
                  backgroundColor: colors.error,
                  color: colors.onError,
                ),
              ),
            if (selectedQuizName == null) ...[
              Column(
                children: [
                  Text(
                    'Todos os quizzes criados',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildQuizList(),
            ] else ...[
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedQuizName = null;
                      });
                    },
                    child: Text('Mostrar todos os quizzes'),
                  ),
                  Text(
                    'Salas de "$selectedQuizName"',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildSessionList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuizList() {
    return Column(
      children: [
        for (dynamic quizName in sessionsByName.keys) ...[
          _buildButton(
            quizName,
            onTap: () {
              setState(() {
                selectedQuizName = quizName;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSessionList() {
    return Column(
      children: [
        for (dynamic session in sessionsByName[selectedQuizName!]) ...[
          _buildButton(
            session['code'],
            colorIndex: ['LOBBY', 'ACTIVE', 'FINISHED'].indexOf(session['status'])+1,
            onTap: () {
              debugPrint('Selected session: ${session['code']} (${session['status']})');
              if (session['status'] != 'FINISHED') {
                tryReconnect(session['code']);
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildButton(String text,{VoidCallback? onTap, int colorIndex = 0}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final buttonCollors = [
      colors.primaryContainer,
      Colors.yellow,
      Colors.green,
      Color(0xFF444444),
    ];
    final buttonTextCollors = [
      colors.onPrimaryContainer,
      Colors.black,
      Colors.white,
      Colors.white,
    ];

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        color: buttonCollors[colorIndex],
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(color: buttonTextCollors[colorIndex], fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
