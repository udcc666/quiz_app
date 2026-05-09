import 'create_server.dart';

typedef CommandHandler = void Function(String clientId, Map<String, dynamic> data);

class ServerCommands {
  static Map<String, CommandHandler> getCommands(Server server) {
    final f = server.functions;

    return {
      // Room Commands
      'add_room': (id, data) => f.room.add(id, data['user_id'], data['quiz_id'], data['settings']),
      'remove_room': (id, data) => f.room.finish(id, data['pin']),
      
      // Participant Commands
      'join_room': (id, data) => f.participant.join(id, data['name'], data['security_code'], data['pin']),
      'leave_room': (id, data) => f.participant.leave(id, data['pin']),

    };
  }
}