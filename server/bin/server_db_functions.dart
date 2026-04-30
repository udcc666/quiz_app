import 'dart:convert';
import 'package:http/http.dart' as http;

final String host = 'http://localhost/quiz_app';
final dynamic headers = {
  'Content-Type': 'application/json; charset=UTF-8',
};

Future<Map<String, dynamic>> createSession(
    int userId, int quizId, Map<String, dynamic> settings) async {
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
  } catch (e) {
    return {'success': false, 'error': 'Failed to connect to backend'};
  }

  if (response.statusCode != 200) {
    return {
      'success': false,
      'error': 'Backend returned code ${response.statusCode}'
    };
  }

  return json.decode(response.body);
}

// Future<bool> canUserEnterQuizz(int quizzId, String name) async {
//   final response = await http.get(Uri.parse('$host/can_user_enter.php?quizz_id=$quizzId&name=$name'));
//   if (response.statusCode != 200) {
//     throw Exception('Failed to load quizzes');
//   }
//   dynamic quizzes = jsonDecode(response.body);

//   if (quizzes['success'] == false){
//     return false;
//   }

//   return quizzes['can_enter'];
// }
