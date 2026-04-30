import 'dart:io';
import 'dart:convert';

import 'server_functions.dart';

class Server {
  bool debug = false;

  int port;
  String ip;

  late final ServerFunctions functions;

  Server(this.ip, this.port) {
    functions = ServerFunctions(this);
  }

  HttpServer? _server;

  Map<String, WebSocket> _clients = {};

  Map<String, dynamic> sessions = {};

  void log(String msg) {
    print(msg);
  }

  void start() async {
    if (_server != null) {
      log("Server already started");
      return;
    }

    log("Starting server at ${port}: ${ip}");

    _server = await HttpServer.bind(ip, port);

    log("Server started at ws://${_server!.address.address}:$port");

    _server!.listen((HttpRequest request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocket socket = await WebSocketTransformer.upgrade(request);

        _on_client_connected(socket);
      }
    });
  }

  void _on_client_connected(WebSocket socket) {
    String clientId = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, dynamic>? data;

    _clients[clientId] = socket;

    if (debug) log('Client $clientId connected');
    socket.listen(
      (message) {
        if (debug) log('Message from $clientId: $message');

        try {
          data = jsonDecode(message);
        } catch (e) {
          log('Error parsing message: $e');
          data = null;
        }

        if (data != null) {
          _handle_data(clientId, data);
          data = null;
        }
      },
      onDone: () => _clients.remove(clientId),
      onError: (err) => _clients.remove(clientId),
    );
  }

  void broadcast2Client(String clientId, Map<String, dynamic> message) {
    var msg = jsonEncode(message);
    var client = _clients[clientId];

    if (client != null) {
      if (client.readyState == WebSocket.open) {
        if (debug) log("Sending to $clientId: $msg");
        client.add(msg);
      }
    }
  }

  void broadcast2Room(String pin, Map<String, dynamic> message) {
    if (!sessions.containsKey(pin)) return;

    List<dynamic> players = sessions[pin]['players'];

    for (var clientId in players) {
      broadcast2Client(clientId, message);
    }
  }

  void _handle_data(String clientId, dynamic data) {
    if (data['type'] == null) {
      return;
    }
    switch (data['type']) {
      case 'add_room':
        functions.host.addRoom(
            clientId, data['user_id'], data['quiz_id'], data['settings']);
        break;
    }
    /*switch (data['type']){
      // Host
      case "create_room":
        functions.host.createRoom(data['pin'], data['quizz_id'], data['name'], clientId);
        break;

      case "delete_room":
        functions.host.deleteRoom(data['pin'], data['name'], clientId);
        break;

      case "get_players":
        functions.host.getPlayers(data['pin'], data['name'], clientId);
        break;

      case "next":
        functions.host.sendNext(data["pin"], data['name'], clientId);
        break;

      case "show_correct_answers":
        functions.host.sendShowCorrectAnwers(data["pin"], data['name'], clientId);
        break;

      case "reconnect":
        functions.host.reconnect(data["pin"], data['name'], clientId);
        break;

      // Client
      case "join_room":
        functions.client.joinRoom(data["pin"], clientId, data['name']);
        break;

      case "quit_room":
        functions.client.quitRoom(data["pin"], clientId);
        break;

      case "message_to_host":
        functions.client.send2Host(data["pin"], data["message"], clientId);
        break;

      case "send_answers":
        //functions.client.saveAnswers(data["pin"], data["answers"], clientId);
        break;


      default:
        log('Unknown message type: ${data['type']}');
        break;
    }*/
  }
}
