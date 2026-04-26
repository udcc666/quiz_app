import 'dart:convert';
import 'package:http/http.dart' as http;

final String host = 'http://localhost/quiz_app';
final dynamic headers = {
  'Content-Type': 'application/json; charset=UTF-8',
};

Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$host/auth/login.php'),
    headers: headers,
    body: jsonEncode({
      'email': email,
      'password': password
    }),
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to login');
  }
}