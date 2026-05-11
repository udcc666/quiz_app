import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:quiz_app/server_functions.dart' as server;

class Client {
  bool debug = false;
  WebSocketChannel? channel;

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onMessage => _eventController.stream;

  bool isConnected = false;

  Future<void> tryConnect() async {
    if (isConnected) {
      debugPrint("Already connected");
      return;
    }

    debugPrint("Connecting to server...");

    channel = WebSocketChannel.connect(Uri.parse(server.server));

    try {
      await channel!.ready;
      debugPrint('Connected to server');
      _whenConnected();
    } catch (e) {
      debugPrint("Unable to connect to server: $e");
    }
  }

  void _whenConnected() {
    isConnected = true;
    channel!.stream.listen(
      (event) {
        if (debug) debugPrint("Received: $event");
        var data = jsonDecode(event);
        _eventController.add(data);
      },
      onError: (error) {
        debugPrint("Error: $error");
        isConnected = false;
      },
      onDone: () {
        debugPrint("Connection closed by the server");
        isConnected = false;
      },
    );
  }

  void disconnect() {
    if (channel == null) {
      return;
    }
    channel!.sink.close();
  }

  void send(String message) {
    if (!isConnected) {
      debugPrint("Not connected");
      return;
    }
    channel!.sink.add(message);
  }
}
