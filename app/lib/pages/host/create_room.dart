import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/imports/quiz.dart';
import 'package:quiz_app/imports/room.dart';
import 'package:quiz_app/db_functions.dart' as db;
import 'package:quiz_app/global.dart' as global;
import 'package:quiz_app/server_functions.dart' as server;

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key, required this.quizId});
  final int quizId;

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  bool isCreating = false;
  dynamic quiz;
  String errorMessage = '';

  final Settings settings = Settings();
  final Settings defaultSettings = Settings();
  bool useDefaultSettings = true;

  @override
  void initState() {
    super.initState();
    if (widget.quizId < 0) {
      context.go('/host/quiz_list');
      return;
    }
    _loadQuiz();
  }

  void _loadQuiz() async {
    final data = await db.getQuizWithId(widget.quizId);
    if (mounted) {
      setState(() {
        quiz = data['quiz'];
        settings.loadJson(quiz);
        defaultSettings.loadJson(quiz);
      });
    }
  }

  void _handleCreate() async {
    if (isCreating) return;
    setState(() => isCreating = true);

    final data = await server.host.addRoom(
      global.userId!,
      widget.quizId,
      settings.toJson(),
    );

    if (!mounted) return;

    if (data['success']) {
      global.room = Room(pin: data['pin']);
      global.room!.settings.loadJson(settings.toJson());
      global.room!.quiz = await Quiz.fromId(widget.quizId);

      if (!mounted) return;
      context.go('/host/monitor/${data['pin']}');
    } else {
      setState(() {
        isCreating = false;
        errorMessage = data['message'] ?? 'Erro ao criar sala';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (quiz == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => context.go('/host/quiz_list'),
                    child: const Text('<- Voltar'),
                  ),
                ],
              ),
            ),

            SwitchListTile(
              title: const Text("Usar definições padrão"),
              value: useDefaultSettings,
              onChanged: (val) {
                setState(() {
                  useDefaultSettings = val;
                  if (useDefaultSettings) {
                    settings.loadJson(quiz);
                  }
                });
              },
            ),

            const Divider(),

            IgnorePointer(
              ignoring: useDefaultSettings,
              child: Opacity(
                opacity: useDefaultSettings ? 0.5 : 1.0,
                child: Column(
                  children: [
                    _buildTile("Controlado pelo Host", settings.hostControlled, (v) {
                      setState(() => settings.hostControlled = v);
                    }),
                    _buildTile("Permitir Entrada Tardia", settings.allowLateEntry, (v) => settings.allowLateEntry = v),
                    _buildTile("Mostrar Classificação", settings.showLeaderboardBetweenQuestions, (v) => settings.showLeaderboardBetweenQuestions = v),
                    _buildTile("Mostrar Respostas", settings.showAnswers, (v) => settings.showAnswers = v),
                    
                    if (settings.hostControlled)
                      _buildTile("Começar no Host", settings.startAtHost, (v) => settings.startAtHost = v),
                    
                    const SizedBox(height: 10),
                    
                    TextField(
                      controller: TextEditingController(text: settings.maxClients?.toString() ?? '')..selection = TextSelection.collapsed(offset: (settings.maxClients?.toString() ?? '').length),
                      decoration: const InputDecoration(labelText: "Limite de Jogadores"),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => settings.maxClients = int.tryParse(v),
                    ),
                    
                    if (!settings.hostControlled) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: TextEditingController(text: settings.duration?.toString() ?? '')..selection = TextSelection.collapsed(offset: (settings.duration?.toString() ?? '').length),
                        decoration: const InputDecoration(labelText: "Duração do quiz (em segundos)"),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => settings.duration = int.tryParse(v),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (errorMessage.isNotEmpty) 
              Text(errorMessage, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: isCreating ? null : _handleCreate,
              child: isCreating ? const CircularProgressIndicator() : const Text("CRIAR SALA"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (v) => setState(() => onChanged(v ?? false)),
    );
  }
}