import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  Map<String, dynamic> defaultSettings = {};
  Map<String, dynamic> settings = {};

  bool useDefaultSettings = true;

  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    if (widget.quizId < 0) {
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
        'show_leaderboard_between_questions':
            quiz['show_leaderboard_between_questions'],
        'show_answers': quiz['show_answers'],
        'allow_late_entry': quiz['allow_late_entry'],
        'start_at_host': quiz['start_at_host'],
      };
      settings = defaultSettings.map((key, value) => MapEntry(key, value));
    });
  }

  void create() async {
    if (isCreating) return;
    setState(() {
      isCreating = true;
      errorMessage = '';
    });

    final Map<String, dynamic> selectedSettings = useDefaultSettings
        ? defaultSettings
        : settings;

    final data = await server.host.addRoom(
      global.userId!,
      widget.quizId,
      selectedSettings,
    );

    if (!data['success']) {
      print('Failed to create session: ${data['error']}');
      setState(() {
        isCreating = false;
        errorMessage = data['message'];
      });
      return;
    }

    print('Session created with code \'${data['pin']}\'');
    
    if (!mounted) return;
    context.go('/host/monitor/${data['pin']}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: isCreating
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            context.go('/host/quiz_list');
                          },
                          child: Text('<- Voltar'),
                        ),
                      ],
                    ),
                  ),

                  if (errorMessage.isNotEmpty)
                    Container(
                      color: colors.error,
                      padding: EdgeInsets.all(5),
                      child: Text(
                        errorMessage,
                        style: TextStyle(fontSize: 24, color: colors.onError),
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

    if (quiz == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Text(
          quiz['name'],
          style: TextStyle(fontSize: 24, color: colors.onSurface),
        ),
        const Divider(),
        buildQuizOptions(),
        const Divider(),
        FilledButton(onPressed: create, child: Text('Criar')),
      ],
    );
  }

  Widget buildQuizOptions() {
    final hostControlled = settings['host_controlled'] ?? false;

    return customExpansionTile(
      title: const Text('Definições'),
      children: [
        _buildCheckbox(
          'Usar definições predefinidas',
          useDefaultSettings,
          onChanged: (bool? newValue) {
            setState(() {
              useDefaultSettings = newValue ?? false;
            });
          },
          onTap: () {
            setState(() {
              useDefaultSettings = !useDefaultSettings;
            });
          },
        ),
        _buildSettingsCheckbox(
          'Controlado pelo host',
          'host_controlled',
          active: !useDefaultSettings,
        ),
        _buildSettingsCheckbox(
          'Permitir entrada após iniciar',
          'allow_late_entry',
          active: !useDefaultSettings,
        ),
        _buildSettingsCheckbox(
          'Mostrar a tabela de classificação entre questões',
          'show_leaderboard_between_questions',
          active: !useDefaultSettings,
        ),
        _buildSettingsCheckbox(
          'Mostrar respostas no fim de cada questão',
          'show_answers',
          active: !useDefaultSettings,
        ),
        _buildSettingsCheckbox(
          'Começar no host',
          'start_at_host',
          active: !useDefaultSettings && hostControlled,
        ),

        _buildNumericField(
          'Limite de pessoas',
          'max_clients',
          canBeNull: true,
          active: !useDefaultSettings,
        ),
        _buildNumericField(
          'Duração',
          'duration',
          canBeNull: true,
          active: !useDefaultSettings && !hostControlled,
        ),
      ],
    );
  }

  Widget customExpansionTile({
    required Widget title,
    required List<Widget> children,
    bool? startExpanded,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final RoundedRectangleBorder shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );

    return ExpansionTile(
      title: title,
      initiallyExpanded: startExpanded ?? false,
      shape: shape,
      collapsedShape: shape,

      collapsedBackgroundColor: colors.surfaceContainer,
      backgroundColor: colors.surfaceContainer,
      childrenPadding: EdgeInsets.all(8),

      children: children,
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value, {
    dynamic onChanged,
    VoidCallback? onTap,
    VoidCallback? onModifiedPressed,
    bool isModified = false,
    bool active = true,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: active ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Checkbox(
              value: value,
              activeColor: colors.primary,
              checkColor: colors.surface,
              side: BorderSide(color: colors.onSurface.withAlpha(150)),
              onChanged: active ? onChanged : null,
            ),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? colors.onSurface
                    : colors.onSurface.withAlpha(150),
                fontSize: 16,
              ),
            ),
            if (isModified)
              IconButton(
                icon: Icon(Icons.restore, size: 18, color: colors.primary),
                onPressed: active ? onModifiedPressed : null,
                tooltip: "Reverter",
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCheckbox(
    String label,
    String key, {
    bool active = true,
  }) {
    // final theme = Theme.of(context);
    // final colors = theme.colorScheme;

    final Map<String, dynamic> selectedSettings = useDefaultSettings
        ? defaultSettings
        : settings;

    return _buildCheckbox(
      label,
      selectedSettings[key],
      isModified: selectedSettings[key] != defaultSettings[key],
      active: active,

      onChanged: (bool? newValue) {
        setState(() {
          selectedSettings[key] = newValue ?? false;
        });
      },
      onTap: () {
        setState(() {
          selectedSettings[key] = !(selectedSettings[key] ?? false);
        });
      },
      onModifiedPressed: () =>
          setState(() => selectedSettings[key] = defaultSettings[key]),
    );
  }

  Widget _buildNumericField(
    String label,
    String key, {
    bool canBeNull = false,
    bool active = true,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final Map<String, dynamic> selectedSettings = useDefaultSettings
        ? defaultSettings
        : settings;

    bool isModified = selectedSettings[key] != defaultSettings[key];
    bool isNull = selectedSettings[key] == null;

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: Key(key + isNull.toString()),
            initialValue: isNull ? '' : selectedSettings[key].toString(),
            enabled: active && !isNull,
            keyboardType: TextInputType.number,
            style: TextStyle(color: colors.onSurface),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: colors.onSurface.withAlpha(150)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: isModified
                  ? IconButton(
                      icon: const Icon(Icons.restore, size: 20),
                      onPressed: () => setState(
                        () => selectedSettings[key] = defaultSettings[key],
                      ),
                    )
                  : null,
            ),
            onChanged: (v) => selectedSettings[key] = int.tryParse(v),
          ),
        ),

        if (canBeNull) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: active
                ? () =>
                      setState(() => selectedSettings[key] = isNull ? 0 : null)
                : null,
            child: Column(
              children: [
                Text(
                  "null",
                  style: TextStyle(
                    color: active
                        ? colors.onSurface
                        : colors.onSurface.withAlpha(150),
                    fontSize: 12,
                  ),
                ),
                Checkbox(
                  value: isNull,
                  onChanged: active
                      ? (v) => setState(
                          () => selectedSettings[key] = v! ? null : 0,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
