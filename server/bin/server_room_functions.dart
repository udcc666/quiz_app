import 'create_server.dart';
import 'classes.dart';
import 'server_db_functions.dart' as db;

class ServerRoomFunctions {
  Server server;
  ServerRoomFunctions(this.server);

  void add(String hostId, int userId, int quizId, Map<String, dynamic> settings) async {
    Map<String, dynamic> message = {
      'type': 'add_room',
      'success': false,
    };

    final data = await db.session.create(userId, quizId, settings);
    if (data['success'] == false) {
      message['error'] = data['error'];
      server.broadcast2Client(hostId, message);
      return;
    }
    
    final pin = data['session_code'];

    server.sessions[pin] = Session(
      dbId: data['session_id'],
      quizId: quizId,
      hostUserId: userId,
      hostSocketID: hostId,
      participants: [],
    );

    server.log("Created session '$pin'");

    message['success'] = true;
    message['pin'] = pin;
    server.broadcast2Client(hostId, message);
  }

  void finish(String hostId, String pin) async {
    Map<String, dynamic> message = {
      'type': 'remove_room',
      'success': false,
    };

    if (!server.sessions.containsKey(pin)) {
      message['error'] = 'Session not found';
      server.broadcast2Client(hostId, message);
      return;
    }

    final session = server.sessions[pin]!;

    if (session.hostSocketID != hostId) {
      message['error'] = 'You are not the host of this session';
      server.broadcast2Client(hostId, message);
      return;
    }

    await db.session.finish(pin);
    server.sessions.remove(pin);
    server.log("Removed session '$pin'");

    message['success'] = true;
    server.broadcast2Client(hostId, message);
  }
}