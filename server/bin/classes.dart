class Session {
  final int dbId;
  final int quizId;
  final String quizName;
  final int hostUserId;
  String hostSocketID;
  List<Participant> participants;

  Session({
    required this.dbId,
    required this.quizId,
    required this.quizName,
    required this.hostUserId,
    required this.hostSocketID,
    this.participants = const [],
  });
}

class Participant {
  String socketId; 
  final int dbId;
  final String name;
  final String securityCode;
  bool isOnline;

  Participant({
    required this.socketId,
    required this.dbId,
    required this.name,
    required this.securityCode,
    this.isOnline = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'participant_id': dbId,
  };
}