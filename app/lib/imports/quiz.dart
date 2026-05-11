import 'package:quiz_app/db_functions.dart' as db;

class Quiz {
  int id;
  String name;
  String description;
  List<Question> questions = [];

  Quiz({
    required this.id,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'questions': questions.map((q) => q.toJson()).toList(),
  };

  static Quiz fromJson(Map<String, dynamic> json) {
    final quiz = Quiz(
      id: json['id'] ?? -1,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
    // quiz.questions = json['questions'].map((q) => Question.fromJson(q)).toList();
    return quiz;
  }

  static Future<Quiz> fromId(int id) async {
    final data = await db.getQuizWithId(id);

    if (data['success'] == false) {
      return Quiz(id: -1, name: '', description: '');
    }

    return Quiz.fromJson(data['quiz']);
  }
}

class Question {
  String question;
  List<Answer> answers;
  int? correctAnswerIndex;

  Question({
    required this.question,
    required this.answers,
    this.correctAnswerIndex,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'answers': answers.map((a) => a.toJson()).toList(),
    'correct_answer_index': correctAnswerIndex,
  };

  static Question fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      answers: json['answers'].map((a) => Answer.fromJson(a)).toList(),
      correctAnswerIndex: json['correct_answer_index'],
    );
  }
}

class Answer {
  String answer;
  bool isCorrect;

  Answer({
    required this.answer,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
    'answer': answer,
    'is_correct': isCorrect,
  };

  static Answer fromJson(Map<String, dynamic> json) {
    return Answer(
      answer: json['answer'],
      isCorrect: json['is_correct'],
    );
  }
}