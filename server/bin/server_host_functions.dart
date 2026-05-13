import 'create_server.dart';
import 'classes.dart';
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
    final data = await db.session.create(userId, quizId, settings);
    if (data['success'] == false) {
      message['error'] = data['error'];
      server.broadcast2Client(hostId, message);
      return;
    }
    final pin = data['session_code'];

    // Success
    server.sessions[pin] = Session(
      dbId: data['session_id'],
      quizId: quizId,
      hostUserId: userId,
      hostSocketID: hostId,
      participants: [],
    );

    server.log("Created session \'$pin\'");

    message['success'] = true;
    message['pin'] = pin;
    server.broadcast2Client(hostId, message);
  }

  void removeRoom(String hostId, String pin) async {
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

    // Remove
    await db.session.finish(pin);

    server.sessions.remove(pin);
    server.log("Removed session \'$pin\'");

    message['success'] = true;
    server.broadcast2Client(hostId, message);
  }

  void reconnect2Room(String hostId, int userId, String pin) async {
    Map<String, dynamic> message = {
      'type': 'reconnect',
      'success': false,
    };

    if (!server.sessions.containsKey(pin)) {
      message['error'] = 'Session not found';
      server.broadcast2Client(hostId, message);
      return;
    }

    final session = server.sessions[pin]!;

    if (session.hostUserId != userId) {
      message['error'] = 'You are not the host of this session';
      server.broadcast2Client(hostId, message);
      return;
    }

    session.hostSocketID = hostId;

    message['success'] = true;
    //message['players'] = session.participants;
    server.broadcast2Room(pin, message);
  }
}
