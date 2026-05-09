import 'package:collection/collection.dart';
import 'create_server.dart';
import 'classes.dart';
import 'server_db_functions.dart' as db;

class ServerParticipantFunctions {
  Server server;
  ServerParticipantFunctions(this.server);

  void add(String clientId, String name, String securityCode, String pin) async {
    pin = pin.toUpperCase();
    Map<String, dynamic> message = {
      'type': 'join_room',
      'success': false,
      'valid_room': false,
    };

    if (!server.sessions.containsKey(pin)) {
      message['error'] = 'Session not found';
      server.broadcast2Client(clientId, message);
      return;
    }
    
    final session = server.sessions[pin]!;
    final Participant? participant = session.participants
      .firstWhereOrNull((p) => p.name == name);

    if (participant != null) {
      if (participant.securityCode != securityCode) {
        message['error'] = 'Name already taken';
        server.broadcast2Client(clientId, message);
        return;
      }

      participant.socketId = clientId;
      message['success'] = true;
      server.broadcast2Client(clientId, message);
      server.broadcast2Host(pin, {
        'type': 'player_joined',
        'name': name,
      });
      return;
    }

    final data = await db.participant.add(
        session.dbId, name, securityCode, DateTime.now());
    
    if (data['success'] == false) {
      message['error'] = data['error'];
      server.broadcast2Client(clientId, message);
      return;
    }

    if (name.length < 3 || name.length > 20) {
      message['error'] = 'Name must be between 3 and 20 characters';
      server.broadcast2Client(clientId, message);
      return;
    }

    session.participants.add(Participant(
      socketId: clientId,
      dbId: data['participant_id'],
      name: name,
      securityCode: securityCode,
    ));
    
    server.log("Client $clientId joined session '$pin'");

    message['valid_room'] = true;
    message['success'] = true;
    server.broadcast2Client(clientId, message);
    server.broadcast2Host(pin, {
      'type': 'player_joined',
      'name': name,
    });
  }

  void left(String clientId, String pin) {
    pin = pin.toUpperCase();
    Map<String, dynamic> message = {
      'type': 'leave_room',
      'success': false,
    };

    if (!server.sessions.containsKey(pin)) {
      message['error'] = 'Session not found';
      server.broadcast2Client(clientId, message);
      return;
    }
    
    final session = server.sessions[pin]!;
    var participant = session.participants
        .firstWhereOrNull((p) => p.socketId == clientId);
    
    if (participant == null) {
      message['error'] = 'You are not in this room';
      server.broadcast2Client(clientId, message);
      return;
    }

    message['success'] = true;
    server.broadcast2Client(clientId, message);
    server.broadcast2Host(pin, {
      'type': 'player_left',
      'name': participant.name,
    });
    server.log("Client $clientId left session '$pin'");
  }
}