import 'create_server.dart';
import 'server_db_functions.dart' as db;

class ServerHostFunctions {
  Server server;
  ServerHostFunctions(this.server);

  Future<void> addRoom(String hostId, int userId, int quizId,
      Map<String, dynamic> settings) async {
    Map<String, dynamic> message = {
      'type': 'add_room',
      'success': false,
    };

    // Create on db
    final data = await db.createSession(userId, quizId, settings);
    if (data['success'] == false) {
      message['error'] = data['error'];
      server.broadcast2Client(hostId, message);
      return;
    }
    final pin = data['session_code'];

    // Success
    server.sessions[pin] = {'host': hostId, 'clients': []};

    server.log("Created session $pin");

    message['success'] = true;
    message['pin'] = pin;
    server.broadcast2Client(hostId, message);
  }
}
