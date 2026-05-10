import 'package:collection/collection.dart';
import 'create_server.dart';
import 'classes.dart';
import 'server_db_functions.dart' as db;

class ServerParticipantFunctions {
  Server server;
  ServerParticipantFunctions(this.server);

  void join(String socketId, String name, String securityCode, String pin) async {
    pin = pin.toUpperCase();
    Map<String, dynamic> message = {
      'type': 'join_room',
      'success': false,
      'valid_room': false,
    };

    if (!server.sessions.containsKey(pin)) {
      message['error'] = 'Session not found';
      server.broadcast.toClient(socketId, message);
      return;
    }
    
    final session = server.sessions[pin]!;
    message['valid_room'] = true;

    final Participant? participant = session.participants
      .firstWhereOrNull((p) => p.name == name);

    if (participant != null) {
      if (participant.securityCode != securityCode) {
        message['error'] = 'Name already taken';
        server.broadcast.toClient(socketId, message);
        return;
      }

      server.socketSession.remove(participant.socketId);
      server.socketSession[socketId] = pin;

      participant.socketId = socketId;
      participant.isOnline = true;

      message['success'] = true;
      server.broadcast.toClient(socketId, message);
      server.functions..room.sendPlayers2Host(socketId, pin);
      return;
    }

    final data = await db.participant.add(
        session.dbId, name, securityCode, DateTime.now());
    
    if (data['success'] == false) {
      message['error'] = data['error'];
      server.broadcast.toClient(socketId, message);
      return;
    }

    if (name.length < 3 || name.length > 20) {
      message['error'] = 'Name must be between 3 and 20 characters';
      server.broadcast.toClient(socketId, message);
      return;
    }

    session.participants.add(Participant(
      socketId: socketId,
      dbId: data['participant_id'],
      name: name,
      securityCode: securityCode,
      isOnline: true,
    ));
    
    server.socketSession[socketId] = pin;
    server.log(msg:"'$name' joined session '$pin'");

    message['success'] = true;
    server.broadcast.toClient(socketId, message);
    server.functions.room.sendPlayers2Host(socketId, pin);
  }

  void leave(String socketId, String pin) {
    pin = pin.toUpperCase();
    Map<String, dynamic> message = {
      'type': 'leave_room',
      'success': false,
    };

    if (!server.sessions.containsKey(pin)) {
      message['error'] = 'Session not found';
      server.broadcast.toClient(socketId, message);
      return;
    }
    
    final session = server.sessions[pin]!;
    var participant = session.participants
        .firstWhereOrNull((p) => p.socketId == socketId);
    
    if (participant == null) {
      message['error'] = 'You are not in this room';
      server.broadcast.toClient(socketId, message);
      return;
    }

    participant.isOnline = false;
    server.socketSession.remove(socketId); 

    message['success'] = true;
    server.broadcast.toClient(socketId, message);
    server.functions.room.sendPlayers2Host(socketId, pin);
    server.log(msg:"'${participant.name}' left session '$pin'");
  }
}