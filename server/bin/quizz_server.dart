import 'create_server.dart';

void main() {
  Server server = Server('127.0.0.1', 1475);
  server.start();
}
