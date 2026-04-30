import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:quiz_app/db_functions.dart' as db;
// import 'package:quiz_app/global.dart' as global;
// import 'package:quiz_app/server_functions.dart' as server;

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key, required this.sessionPin});

  final String sessionPin;

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colors = theme.colorScheme;

    return Scaffold(body: Center(child: Text('Pin: ${widget.sessionPin}')));
  }
}
