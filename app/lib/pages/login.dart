import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/db_functions.dart' as db;
import 'package:quiz_app/global.dart' as global;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String errorMessage = '';

  bool showPassword = false;

  @override
  void initState() {
    super.initState();

    if (global.userId != null){
      Future.microtask(() {
        if (mounted) context.go('/');
      });
    }

  }

  void login() async {
    Map<String, dynamic> data = await db.login(
      _emailController.text, 
      _passwordController.text
    );
    print(data);
    if (data['success'] == false) {
      setState(() {
        errorMessage = data['error'] ?? 'Failed to login';
      });
      return;
    }
    TextInput.finishAutofillContext();
    setState(() {
      errorMessage = '';
    });

    global.userId = data['user_id'];
    global.username = data['username'];

    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          child: AutofillGroup(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () { context.go('/'); }, 
                      child: Text('<- Voltar')
                    ),
                  ],
                ),
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                if (errorMessage.isNotEmpty)
                  Container(
                    color: colors.error,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                        fontSize: 24,
                        color: colors.onError
                      ),
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    hintText: 'Email'
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: !showPassword,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    hintText: 'Palavra passe',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      }, 
                      icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: login, 
                  child: Text('Entrar')
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}