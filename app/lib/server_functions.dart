import 'dart:convert';

import 'package:quiz_app/global.dart' as global;

final String server = 'ws://localhost:1475';

class Host {
  Future<dynamic> getData(String type, dynamic message) {
    var msg = jsonEncode(message);

    global.client.send(msg);

    return global.client.onMessage.where((data) => data['type'] == type).first;
  }

  Future<Map<String, dynamic>> addRoom(
    int userId,
    int quizId,
    Map<String, dynamic> settings,
  ) async {
    if (!global.client.isConnected) {
      print("Not connected");
      return {'success': false, 'message': 'Not connected to server'};
    }

    return await getData('add_room', {
      'type': 'add_room',
      'user_id': userId,
      'quiz_id': quizId,
      'settings': settings,
    });
  }

  Future<Map<String, dynamic>> removeRoom(String pin) async {
    if (!global.client.isConnected) {
      print("Not connected");
      return {'success': false, 'message': 'Not connected to server'};
    }

    return await getData('remove_room', {'type': 'remove_room', 'pin': pin});
  }
}

class Client {
  Future<dynamic> getData(String type, dynamic message) {
    var msg = jsonEncode(message);

    global.client.send(msg);

    return global.client.onMessage.where((data) => data['type'] == type).first;
  }

  Future<Map<String, dynamic>> joinRoom(String name, String pin) async {
    if (!global.client.isConnected) {
      print("Not connected");
      return {'success': false, 'message': 'Not connected to server'};
    }

    return await getData('join_room', {
      'type': 'join_room',
      'name': name,
      'pin': pin,
    });
  }

  Future<Map<String, dynamic>> leaveRoom(String pin) async {
    if (!global.client.isConnected) {
      print("Not connected");
      return {'success': false, 'message': 'Not connected to server'};
    }

    return await getData('leave_room', {
      'type': 'leave_room',
      'pin': pin,
    });
  }
}

final host = Host();
final client = Client();
