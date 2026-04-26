import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              ElevatedButton(
                onPressed: () { context.go('/'); }, 
                child: Text('Voltar')
              ),
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Email'
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Palavra passe'
                ),
              ),
              ElevatedButton(
                onPressed: () {}, 
                child: Text('Entrar')
              ),
            ],
          ),
        ),
      ),
    );
  }
}