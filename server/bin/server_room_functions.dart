import 'create_server.dart';
import 'classes.dart';
import 'server_db_functions.dart' as db;

class ServerRoomFunctions {
  Server server;
  ServerRoomFunctions(this.server);

  void add(String socketId, int userId, int quizId, Map<String, dynamic> settings) async {
    Map<String, dynamic> message = {
      'type': 'add_room',
      'success': false,
    };

    final data = await db.session.create(userId, quizId, settings);
    if (data['success'] == false) {
      message['error'] = data['error'];
      server.broadcast.toClient(socketId, message);
      return;
    }
    
    final pin = data['session_code'];

    server.sessions[pin] = Session(
      dbId: data['session_id'],
      quizId: quizId,
      hostUserId: userId,
      hostSocketID: socketId,
      participants: [],
    );

    server.log(msg:"Created session '$pin'");

    message['success'] = true;
    message['pin'] = pin;
    server.broadcast.toClient(socketId, message);
  }

  void finish(String socketId, String pin) async {
    Map<String, dynamic> message = {
      'type': 'remove_room',
      'success': false,
    };

    if (!server.sessions.containsKey(pin)) {
      message['error'] = 'Session not found';
      server.broadcast.toClient(socketId, message);
      return;
    }

    final session = server.sessions[pin]!;

    if (session.hostSocketID != socketId) {
      message['error'] = 'You are not the host of this session';
      server.broadcast.toClient(socketId, message);
      return;
    }

    await db.session.finish(pin);
    server.sessions.remove(pin);
    server.log(msg:"Removed session '$pin'");

    message['success'] = true;
    server.broadcast.toClient(socketId, message);
  }

  void reconnect(String socketId, int userId, String pin) async {
    pin = pin.toUpperCase().trim();
    
    Map<String, dynamic> message = {
      'type': 'reconnect_host',
      'success': false,
    };

    if (!server.sessions.containsKey(pin)) {
      message['error'] = 'Session not found';
      server.broadcast.toClient(socketId, message);
      return;
    }

    final session = server.sessions[pin]!;

    if (session.hostUserId != userId) {
      message['error'] = 'Unauthorized: You are not the host of this session';
      server.broadcast.toClient(socketId, message);
      return;
    }

    // Success
    session.hostSocketID = socketId;
    //server.log(msg:"Host (User ID: $userId) reconnected to session '$pin'");

    message['success'] = true;
    message['pin'] = pin;
    message['participants'] = session.participants.map((p) => {
      'name': p.name,
      'dbId': p.dbId,
    }).toList();

    server.broadcast.toClient(socketId, message);
  }

}