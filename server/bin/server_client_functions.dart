import 'create_server.dart';

// import 'server_db_functions.dart' as db;

class ServerClientFunctions {
  Server server;
  ServerClientFunctions(this.server);

  void joinRoom(String clientId, String name, String pin) {
    pin = pin.toUpperCase();
    Map<String, dynamic> message = {
      'type': 'join_room',
      'success': false,
      'valid_room': false,
    };

    // Checks
    if (!server.sessions.containsKey(pin)) {
      message['error'] = 'Session not found';
      server.broadcast2Client(clientId, message);
      return;
    }
    
    message['valid_room'] = true;

    if (name.length < 3 || name.length > 20) {
      message['error'] = 'Name must be between 3 and 20 characters';
      server.broadcast2Client(clientId, message);
      return;
    }
    
    if (server.sessions[pin]['clients'].any((client) => client['name'] == name)) {
      message['error'] = 'Name already taken';
      server.broadcast2Client(clientId, message);
      return;
    }

    // Success
    server.sessions[pin]['clients'].add({
      'id': clientId,
      'name': name,
    });
    server.log("Client $clientId joined session \'$pin\'");

    message['success'] = true;
    server.broadcast2Client(clientId, message);
    
  }
  
}