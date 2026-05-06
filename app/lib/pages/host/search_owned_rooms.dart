import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/db_functions.dart' as db;
import 'package:quiz_app/global.dart' as global;
// import 'package:quiz_app/server_functions.dart' as server;

class SearchOwnedRoomsPage extends StatefulWidget {
  const SearchOwnedRoomsPage({super.key});

  @override
  State<SearchOwnedRoomsPage> createState() => _SearchOwnedRoomsPageState();
}

class _SearchOwnedRoomsPageState extends State<SearchOwnedRoomsPage> {
  String? sessionErrorMessage;

  bool loading = true;
  List<dynamic> sessions = [];

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
    print('data: $data');
    if (!mounted) return;
    
    if (data['success'] == false) {
      setState(() {
        sessionErrorMessage = data['error'];
        loading = false;
      });
      return;
    }
    
    setState(() {
      sessions = data['sessions'];
      sessionErrorMessage = null;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colors = theme.colorScheme;

    if (loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
        ],
      ),
    );
  }

  Widget buildSessionList() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Flexible(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            if (sessionErrorMessage != null)
              Text(
                sessionErrorMessage!,
                style: TextStyle(
                  backgroundColor: colors.error,
                  color: colors.onError,
                ),
              ),

            for (dynamic session in sessions) ...[_buildQuizButton(sessions)],
          ],
        ),
      ),
    );
  }

  Widget _buildQuizButton(dynamic session) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: () {
        // loadQuizWithId(int.tryParse(quiz['id']) ?? -1);
      },
      child: Container(
        width: double.infinity,
        height: 50,
        color: colors.primaryContainer,
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Text(
              session['name'],
              style: TextStyle(color: colors.onPrimaryContainer, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
