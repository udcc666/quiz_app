class Session {
  final int dbId;
  final int quizId;
  final int hostUserId;
  String hostSocketID;
  List<Participant> participants;

  Session({
    required this.dbId,
    required this.quizId,
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

  Participant({
    required this.socketId,
    required this.dbId,
    required this.name,
    required this.securityCode,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'participant_id': dbId,
  };
}