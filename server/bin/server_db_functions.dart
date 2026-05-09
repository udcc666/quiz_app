import 'dart:convert';
import 'package:http/http.dart' as http;

final String _host = 'http://localhost/quiz_app';
final Map<String, String> _headers = {
  'Content-Type': 'application/json; charset=UTF-8',
};

// Função privada auxiliar para processar qualquer pedido
Future<Map<String, dynamic>> _processRequest(Future<http.Response> request) async {
  try {
    final response = await request;
    if (response.statusCode == 200) return json.decode(response.body);
    return {'success': false, 'error': 'Erro: ${response.statusCode}'};
  } catch (e) {
    return {'success': false, 'error': 'Falha na conexão: $e'};
  }
}

// Agrupamento para Sessions
class session {
  static Future<Map<String, dynamic>> getAll() {
    return _processRequest(http.get(Uri.parse('$_host/session/server_get_all.php')));
  }

  static Future<Map<String, dynamic>> create(int userId, int quizId, Map<String, dynamic> settings) {
    return _processRequest(
      http.post(
        Uri.parse('$_host/session/create.php'),
        headers: _headers,
        body: jsonEncode({'user_id': userId, 'quiz_id': quizId, 'settings': settings}),
      ),
    );
  }

  static Future<Map<String, dynamic>> finish(String pin) {
    return _processRequest(
      http.post(
        Uri.parse('$_host/session/finish.php'),
        headers: _headers,
        body: jsonEncode({'pin': pin}),
      ),
    );
  }
}

// Agrupamento para Participants
class participant {
  static Future<Map<String, dynamic>> add(int sessionId, String name, String code, DateTime date) {
    return _processRequest(
      http.post(
        Uri.parse('$_host/participants/create.php'),
        headers: _headers,
        body: jsonEncode({
          'session_id': sessionId,
          'username': name,
          'recovery_code': code,
          'started_at': date.toIso8601String(),
        }),
      ),
    );
  }
}