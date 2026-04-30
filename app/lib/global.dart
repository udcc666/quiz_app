import 'package:quiz_app/client.dart';

final Client client = Client();

int? userId = 1;
String username = 'Nelson';

void logout() {
  userId = null;
  username = '';
}