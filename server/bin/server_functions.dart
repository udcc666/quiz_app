import 'create_server.dart';
import 'server_room_functions.dart';
import 'server_participant_functions.dart';

class ServerFunctions {
  Server server;
  // late final ServerHostFunctions host;
  // late final ServerClientFunctions client;
  late final ServerRoomFunctions room;
  late final ServerParticipantFunctions participant;
  
  ServerFunctions(this.server){
    // host = ServerHostFunctions(server);
    // client = ServerClientFunctions(server);
    room = ServerRoomFunctions(server);
    participant = ServerParticipantFunctions(server);
  }
}