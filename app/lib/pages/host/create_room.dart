import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/db_functions.dart' as db;
import 'package:quiz_app/global.dart' as global;

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key, required this.quizId});

  final int quizId;

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {

  dynamic quiz;

  Map<String, dynamic> defaultSettings = {};
  Map<String, dynamic> settings = {};
  

  @override
  void initState() {
    super.initState();

    if (widget.quizId < 0){
      context.go('/host/quiz_list');
      return;
    }

    loadQuiz();
  }

  void loadQuiz() async {
    dynamic data = await db.getQuizWithId(widget.quizId);
    setState(() {
      quiz = data['quiz'];
      defaultSettings = {
        'host_controlled': quiz['host_controlled'],
        'duration': quiz['duration'],
        'max_clients': quiz['max_clients'],
        'show_leaderboard_between_questions': quiz['show_leaderboard_between_questions'],
        'show_answers': quiz['show_answers'],
        'allow_late_entry': quiz['allow_late_entry'],
        'start_at_host': quiz['start_at_host'],
      };
      settings = defaultSettings.map((key, value) => MapEntry(key, value));
    });
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colors = theme.colorScheme;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () { context.go('/host/quiz_list'); }, 
                    child: Text('<- Voltar')
                  ),
                ],
              ),
            ),
            buildQuizDetails(),
          ],
        ),
      ),
    );
  }

  Widget buildQuizDetails() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    if (quiz == null){
      return Center(child: CircularProgressIndicator(),);
    }

    return Column(
      children: [
        Text(quiz['name'],
          style: TextStyle(
            fontSize: 24,
            color: colors.onSurface,
          ),
        ),
        Column(
          children: [
            _buildCheckboxField('Host controlled', 'host_controlled'),
            _buildCheckboxField('Allow late entry', 'allow_late_entry'),
            _buildCheckboxField('Show leaderboard between questions', 'show_leaderboard_between_questions'),
            _buildCheckboxField('Show answers', 'show_answers'),
            _buildCheckboxField('Start at host', 'start_at_host'),

            _buildNumericField('Max clients', 'max_clients', canBeNull: true),
            _buildNumericField('Duration', 'duration', canBeNull: true),
            
          ],
        ),
      ],
    );
  }

  Widget _buildCheckboxField(String label, String key) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    bool isModified = settings[key] != defaultSettings[key];

    print('$label: ${settings[key]}');
    
    return InkWell(
      onTap: () {
        setState(() {
          settings[key] = !(settings[key] ?? false);
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Checkbox(
              value: settings[key],
              activeColor: colors.primary,
              checkColor: colors.surface,
              side: BorderSide(color: colors.onSurface.withAlpha(150)),
              onChanged: (bool? newValue) {
                setState(() {
                  settings[key] = newValue ?? false;
                });
              },
            ),
            Text(
              label,
              style: TextStyle(color: colors.onSurface, fontSize: 16),
            ),
            if (isModified)
              IconButton(
                icon: Icon(Icons.restore, size: 18, color: colors.primary),
                onPressed: () => setState(() => settings[key] = defaultSettings[key]),
                tooltip: "Reverter",
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericField(String label, String key, {bool canBeNull = false}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    bool isModified = settings[key] != defaultSettings[key];
    bool isNull = settings[key] == null;

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: Key(key + isNull.toString()),
            initialValue: isNull ? '' : settings[key].toString(),
            enabled: !isNull,
            keyboardType: TextInputType.number,
            style: TextStyle(color: colors.onSurface),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: colors.onSurface.withAlpha(150)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: isModified 
                ? IconButton(
                    icon: const Icon(Icons.restore, size: 20),
                    onPressed: () => setState(() => settings[key] = defaultSettings[key]),
                  ) 
                : null,
            ),
            onChanged: (v) => settings[key] = int.tryParse(v),
          ),
        ),
        
        if (canBeNull) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => settings[key] = isNull ? 0 : null),
            child: Column(
              children: [
                const Text("null", style: TextStyle(fontSize: 12)),
                Checkbox(
                  value: isNull,
                  onChanged: (v) => setState(() => settings[key] = v! ? null : 0),
                ),
              ],
            ),
            
          ),
        ],
      ],
    );
  }

}