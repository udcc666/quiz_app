import 'create_server.dart';
import 'server_host_functions.dart';
import 'server_client_functions.dart';

class ServerFunctions {
  Server server;
  late final ServerHostFunctions host;
  late final ServerClientFunctions client;
  
  ServerFunctions(this.server){
    host = ServerHostFunctions(server);
    client = ServerClientFunctions(server);
  }
}