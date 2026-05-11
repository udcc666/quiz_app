import 'package:quiz_app/client.dart';
// import 'package:quiz_app/imports/classes.dart';
import 'package:quiz_app/imports/room.dart';
// import 'package:quiz_app/imports/quiz.dart';

final Client client = Client();

// Room
Room? room;

// User
int? userId = 1;
String username = 'Nelson';

void logout() {
  userId = null;
  username = '';
}