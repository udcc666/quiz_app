import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:quiz_app/app_theme.dart';
import 'package:go_router/go_router.dart';
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
      themeMode: ThemeMode.dark,
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
          children: [
            if (hasAccount) ...[
              Text('Olá ${global.username}'),
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
            ]
              
          ],
        ),
      ),
    );
  }
}
