import 'dart:io';
import 'dart:convert';
import 'classes.dart';
import 'server_functions.dart';
import 'server_db_functions.dart' as db;
import 'server_commands.dart';

typedef CommandHandler = void Function(String clientId, Map<String, dynamic> data);

class Server {
  bool debug = false;

  int port;
  String ip;

  late final Map<String, CommandHandler> _commands;
  late final ServerFunctions functions;
  late final ServerBroadcast broadcast;

  Server(this.ip, this.port) {
    functions = ServerFunctions(this);
    broadcast = ServerBroadcast(this);
    _commands = ServerCommands.getCommands(this);
  }

  HttpServer? _server;

  Map<String, WebSocket> _clients = {};

  Map<String, Session> sessions = {};

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

    await _loadServerData();

    _server!.listen((HttpRequest request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocket socket = await WebSocketTransformer.upgrade(request);

        _on_client_connected(socket);
      }
    });
  }

  Future<void> _loadServerData() async {
    print('Loading sessions from db');

    var data = await db.session.getAll();
    
    if (data['success'] == false) {
      log('Error loading sessions: ${data['error']}');
      return;
    }
    
    for (var session in data['sessions']) {
      List<Participant> clients = [];

      for (var client in session['participants']) {
        /**{
          'id': '',  // id = clientId
          'participant_id': client['id'],
          'name': client['username'],
          'security_code': client['recovery_code'],
        } */
        clients.add(Participant(
            socketId: '',
            dbId: client['id'],
            name: client['username'],
            securityCode: client['recovery_code'],
          ),
        );
      }
    
      sessions[session['code']] = Session(
        dbId: session['id'],
        quizId: session['quiz_id'],
        hostUserId: session['host_id'],
        hostSocketID: '',
        participants: clients,
      );
    }
    print('Loaded ${data['sessions'].length} sessions');
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

  void _handle_data(String clientId, dynamic data) {
    if (data is! Map<String, dynamic> || data['type'] == null) return;

    final String type = data['type'];
    final handler = _commands[type];

    if (handler == null) {
      log('Unknown message type: ${data['type']}');
      return;
    }

    handler!(clientId, data);
  }
}

class ServerBroadcast {
  final Server server;
  ServerBroadcast(this.server);

  void toClient(String clientId, Map<String, dynamic> message) {
    final socket = server._clients[clientId];
    if (socket != null) {
      socket.add(jsonEncode(message));
    }
  }

  void toHost(String pin, Map<String, dynamic> message) {
    final session = server.sessions[pin];
    if (session != null && session.hostSocketID.isNotEmpty) {
      toClient(session.hostSocketID, message);
    }
  }

  void toRoom(String pin, Map<String, dynamic> message) {
    final session = server.sessions[pin];
    if (session == null) return;

    for (var participant in session.participants) {
      if (participant.socketId.isNotEmpty) {
        toClient(participant.socketId, message);
      }
    }
  }

  void toAllInRoom(String pin, Map<String, dynamic> message) {
    toHost(pin, message);
    toRoom(pin, message);
  }
}