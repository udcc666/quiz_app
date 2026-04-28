import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/db_functions.dart' as db;
import 'package:quiz_app/global.dart' as global;

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  
  bool loading = false;
  String? quizzesErrorMessage;
  List<dynamic> quizzes = [];

  bool loadingSelectedQuiz = false;
  String? quizErrorMessage;
  dynamic selectedQuiz;

  @override
  void initState() {
    super.initState();
    getQuizzes();
  }

  void getQuizzes() async {
    if (loading) return;

    dynamic data = await db.getQuizzes();

    if (data['success'] == false){
      setState(() {
        loading = false;
        quizzesErrorMessage = data['error'];
      });
      return;
    }

    setState(() {
      quizzes = data['quizzes'];
      loading = false;
      quizErrorMessage = null;
    });
  }

  void loadQuizWithId(int id) async {
    if (id == -1) return;
    if (loadingSelectedQuiz) return;

    setState(() {
      loadingSelectedQuiz = true;
    });

    dynamic data = await db.getQuizWithId(id);
  
    if (data['success'] == false){
      setState(() {
        loadingSelectedQuiz = false;
        quizErrorMessage = data['error'];
      });
      return;
    }

    setState(() {
      selectedQuiz = data['quiz'];
      loadingSelectedQuiz = false;
      quizErrorMessage = null;
    });

  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colors = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () { context.go('/'); }, 
                      child: Text('<- Voltar')
                    ),
                  ],
                ),
              ),
              if (loading) Center(child: CircularProgressIndicator())
              else buildQuizList(),
            ],
          ),
          buildSelectedQuizDetails(),
        ],
      )
    );
  }

  Widget buildQuizList() {
    // final theme = Theme.of(context);
    // final colors = theme.colorScheme;

    return Flexible(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            if (quizzesErrorMessage != null) 
              Text(quizzesErrorMessage!),
            
            for (dynamic quiz in quizzes) ...[
              _buildQuizButton(quiz),
            ],

          ],
        ),
      ),
    );
  }

  Widget _buildQuizButton(dynamic quiz) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: () {
        loadQuizWithId(int.tryParse(quiz['id']) ?? -1);
      },
      child: Container(
        width: double.infinity,
        height: 50,
        color: colors.primaryContainer,
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Text(
              quiz['name'],
              style: TextStyle(
                color: colors.onPrimaryContainer,
                fontSize: 18
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSelectedQuizDetails() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (selectedQuiz == null && !loadingSelectedQuiz){
      return Center();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedQuiz = null;
        });
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withAlpha(100),
        child: Center(
          child: selectedQuiz == null
          ? CircularProgressIndicator()
          : GestureDetector(
            onTap: () {},
            child: Container(
              width: 500,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedQuiz['name'],
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 24
                      ),
                    ),
                    const Divider(),
                    Text(
                      selectedQuiz['description'],
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 18
                      ),
                    ),
                    const Divider(),
                    FilledButton(
                      onPressed: () { 
                        context.go('/host/create_quiz/${selectedQuiz['id']}'); 
                      }, 
                      child: Text('Criar sala')
                    ),
                  ],
                ),
            ),
          ),
        ),
      ),
    );
  }

}