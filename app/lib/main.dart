import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:quiz_app/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/pages/host/create_room.dart';
import 'package:quiz_app/pages/host/quiz_list.dart';
import 'package:quiz_app/pages/login.dart';
import 'package:quiz_app/global.dart' as global;

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    // Host
    GoRoute(
      path: '/host/quiz_list',
      builder: (context, state) => const QuizListPage(),
    ),
    GoRoute(
      path: '/host/create_quiz/:id',
      builder: (context, state) {
        final int id = int.tryParse(state.pathParameters['id']??'-1') ?? -1;
        
        return CreateRoomPage(quizId: id);
      },
    ),
  ],
);

void main() {
  usePathUrlStrategy();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool get hasAccount => global.userId != null;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            if (hasAccount) ...[
              Text('Olá ${global.username}!'),
              ElevatedButton(
                onPressed: () { 
                  global.logout(); 
                  setState(() {});
                }, 
                child: Text('Logout'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () { context.go('/login'); }, 
                child: Text('Login page'),
              ),
            ],
            ElevatedButton(
              onPressed: () { context.go('/host/quiz_list'); }, 
              child: Text('QuizList page'),
            ),
              
          ],
        ),
      ),
    );
  }
}
