import 'dart:convert';
import 'package:http/http.dart' as http;

final String host = 'http://localhost/quiz_app';
final dynamic headers = {
  'Content-Type': 'application/json; charset=UTF-8',
};

Future<Map<String, dynamic>> login(String email, String password) async {
  late dynamic response;
  try {
    response = await http.post(
      Uri.parse('$host/auth/login.php'),
      headers: headers,
      body: jsonEncode({
        'email': email,
        'password': password
      }),
    );
  } catch(e){
    return {'success': false, 'error': 'Failed to connect to backend'};
  }

  if (response.statusCode != 200) {
    return {'success': false, 'error': 'Backend returned code ${response.statusCode}'};
  }

  return json.decode(response.body);
}

Future<Map<String, dynamic>> getQuizzes() async {
  late dynamic response;
  try {
    response = await http.get(
      Uri.parse('$host/quiz/get_quiz_list.php'),
      headers: headers,
    );
  } catch(e){
    return {'success': false, 'error': 'Failed to connect to backend'};
  }

  if (response.statusCode != 200) {
    return {'success': false, 'error': 'Backend returned code ${response.statusCode}'};
  }

  return json.decode(response.body);
}

Future<Map<String, dynamic>> getQuizWithId(int id) async {
  late dynamic response;
  try {
    response = await http.get(
      Uri.parse('$host/quiz/get_quiz.php?id=$id'),
      headers: headers,
    );
  } catch(e){
    return {'success': false, 'error': 'Failed to connect to backend'};
  }

  if (response.statusCode != 200) {
    return {'success': false, 'error': 'Backend returned code ${response.statusCode}'};
  }

  return json.decode(response.body);
}

/* Future<Map<String, dynamic>> createSession(int userId, int quizId, Map<String, dynamic> settings) async {
  late dynamic response;
  
  try {
    response = await http.post(
      Uri.parse('$host/session/create.php'),
      headers: headers,
      body: jsonEncode({
        'user_id': userId,
        'quiz_id': quizId,
        'settings': settings,
      }),
    );
  } catch(e){
    return {'success': false, 'error': 'Failed to connect to backend'};
  }

  if (response.statusCode != 200) {
    return {'success': false, 'error': 'Backend returned code ${response.statusCode}'};
  }
  
  return json.decode(response.body);
}*/